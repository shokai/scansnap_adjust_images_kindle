#!/usr/bin/env jruby
# -*- coding: utf-8 -*-
# ディレクトリ内の画像を全てkindleで読みやすいように2値化、アンチエイリアス、リサイズする
# イラストも2値化されるので、小説などの文字ページ専用。
require 'rubygems'
require 'ArgsParser'
require 'java'
import 'java.lang.System'
import 'javax.imageio.ImageIO'
import 'java.awt.image.BufferedImage'
import 'java.awt.image.WritableRaster'
import 'java.awt.image.AffineTransformOp'
import 'java.awt.geom.AffineTransform'
import 'java.awt.Color'
$KCODE = 'u'

parser = ArgsParser.parser
parser.bind(:width, :w, 'width')
parser.bind(:height, :h, 'height')
parser.bind(:input, :i, 'input')
parser.bind(:output, :o, 'output')
parser.bind(:cleft, :cl, 'crop left (pixel)')
parser.bind(:cright, :cr, 'crop right (pixel)')
parser.bind(:ctop, :ct, 'crop top (pixel)')
parser.bind(:cbottom, :cb, 'crop bottom (pixel)')
parser.bind(:threshold, :t, 'threshold of binarize (0-255)')
first, params = parser.parse(ARGV)

if !parser.has_params([:width, :height, :input, :output, :threshold]) or
    parser.has_option(:help)
  puts parser.help
  puts 'e.g. jruby kindlize_images.rb -i /path/to/in_dir/ -o /path/to/out_dir/ -w 1200 -h 1600 -t 240'
  puts 'e.g. jruby kindlize_images.rb -i /path/to/in_dir/ -o /path/to/out_dir/ -w 1200 -h 1600 -cleft 50 -cright 50 -ctop 80 -cbottom 100 -t 240'
  exit 1
end
  
p params
WIDTH = params[:width].to_i
HEIGHT = params[:height].to_i
Dir.mkdir(params[:output]) unless File.exists? params[:output]
params[:output] += '/' unless params[:output] =~ /\/$/

Dir.glob(params[:input]+'*').each{|i|
  puts i
  begin
    img = ImageIO.read(java.io.File.new(i))
  rescue => e
    STDERR.puts 'image load error'
    STDERR.puts e
    next
  end
  puts "size : #{img.width}x#{img.height}"
  
  if params[:cleft] or params[:cright] or params[:ctop] or params[:cbottom]
    params[:cleft] = 0 unless params[:cleft]
    params[:cright] = 0 unless params[:cright]
    params[:ctop] = 0 unless params[:ctop]
    params[:cbottom] = 0 unless params[:cbottom]
    img = img.get_subimage(params[:cleft].to_i, params[:ctop].to_i,
                           img.width-params[:cleft].to_i-params[:cright].to_i, 
                           img.height-params[:ctop].to_i-params[:cbottom].to_i)
    puts "crop : #{img.width}x#{img.height}"
  end

  # リサイズ
  if img.width.to_f/img.height > WIDTH.to_f/HEIGHT # 指定されたWIDTH,HEIGHTよりも横長の画像
    scale = WIDTH.to_f/img.width
    img_resized = BufferedImage.new(WIDTH, (scale*img.height).to_i, img.type)
  else # 縦長
    scale = HEIGHT.to_f/img.height
    img_resized = BufferedImage.new((scale*img.width).to_i, HEIGHT, img.type)
  end
  puts "scale : #{scale}"
  AffineTransformOp.new(AffineTransform.getScaleInstance(scale, scale), nil).filter(img, img_resized)
  puts "resized : #{img_resized.width}x#{img_resized.height}"

  # 固定サイズ画像にはめこむ
  img_frame = BufferedImage.new(WIDTH, HEIGHT, img.type)
  graph = img_frame.graphics
  graph.color = Color.new(255,255,255)
  graph.fillRect(0, 0, WIDTH, HEIGHT)
  if WIDTH > img_resized.width
    graph.drawImage(img_resized, (WIDTH-img_resized.width)/2, 0, nil)
  else
    graph.drawImage(img_resized, 0, (HEIGHT-img_resized.height)/2, nil)
  end
  puts "set in frame : #{img_frame.width}x#{img_frame.height}"
  img = img_frame

  # 2値化
  for y in 0...img.height do
    for x in 0...img.width do
      pix = img.get_rgb(x, y)
      r = pix >> 16 & 0xFF
      g = pix >> 8 & 0xFF
      b = pix & 0xFF
      gray = (r+g+b)/3
      if gray > params[:threshold].to_i
        pix = 0xFFFFFF
      else
        pix = 0x000000
      end
      img.set_rgb(x, y, pix)
    end
  end
  puts "binarize"

  # 膨張
  img_dilated = BufferedImage.new(img.width, img.height, img.type)
  for y in 1...img.height-1 do
    for x in 1...img.width-1 do
      if img.get_rgb(x, y)&0xFF == 0
        img_dilated.set_rgb(x, y, 0x000000)
      elsif img.get_rgb(x-1, y)&0xFF == 0 or img.get_rgb(x+1, y)&0xFF == 0 or
          img.get_rgb(x, y-1)&0xFF == 0 or img.get_rgb(x,y+1)&0xFF == 0
        img_dilated.set_rgb(x, y, 0x999999)
      else
        img_dilated.set_rgb(x, y, 0xFFFFFF)
      end
    end
  end
  img = img_dilated
  puts "dilate"

  out_name = i.split(/\//).last
  out_type = 'bmp'
  begin
    ImageIO.write(img, out_type, java.io.File.new(params[:output]+out_name))
    puts 'saved! => '+params[:output]+out_name
  rescue => e
    STDERR.puts 'image save error'
    STDERR.puts e
    next
  end
}

