local render_cut = false

local cfg = {
  ep=6.7,
  kerf=0.2,
  base = {
    len=200,
    width=25,
    height=135,
    delta=20,
    middle={}
  },
  stabil = {
    width=80
  },
  axis = {
    radius = 1.1,
    pos={2.5,3,4.5,5}
  },
  bras={
    len=150,
    axis={
      pos={0.5, 1}
    }
  }
}

if not render_cut then
  cfg.kerf = -0.5 -- Just to better render the inter-parts locking
end

cfg.stabil.pos = -cfg.base.len/2+cfg.base.width

local base = union{
  cube(cfg.base.len, cfg.ep, cfg.base.width),
  translate(cfg.base.delta, 0, 0) * 
    union{
      cube(cfg.base.width, cfg.ep, cfg.base.height),
      translate(-15,0,10) *
        intersection{
          rotate(0,45,0) *
            cube(40, cfg.ep, 40),
          cube(90, cfg.ep, 60)
        }
    }
}

local axis = translate(cfg.base.delta,0,0) * rotate(90,0,0) * translate(0, 0, -2.5*cfg.ep) * cylinder(cfg.axis.radius, 5*cfg.ep)

local all_axis = {}
for i, pos in ipairs(cfg.axis.pos) do
  all_axis[i] = translate(0,0,pos*cfg.base.width) * axis
end
axis = union(all_axis)

base=difference{
  base,
  axis,
  translate(cfg.stabil.pos,0,0) * 
    cube(cfg.ep - 2*cfg.kerf, 2*cfg.ep, cfg.base.width/2),
}

local base_left = base
cfg.base.middle.len = 2/3*cfg.base.len
local base_middle = 
    intersection{
      base,
      cube(cfg.base.middle.len, cfg.ep, 2*cfg.base.width)
    }
local base_right = base


local stabil = 
    difference{
      cube(cfg.ep, cfg.stabil.width, cfg.base.width),
      translate(0,cfg.ep,cfg.base.width/2) * 
        cube(2*cfg.ep, cfg.ep - 2*cfg.kerf, cfg.base.width/2),
      translate(0,-cfg.ep,cfg.base.width/2) * 
        cube(2*cfg.ep, cfg.ep - 2*cfg.kerf, cfg.base.width/2)
    }

local bras = difference{
  ccube(cfg.bras.len, cfg.ep, cfg.base.width),
  translate((cfg.bras.len-cfg.base.width)/2,0,0) * rotate(90,0,0) * ccylinder(cfg.axis.radius, 2*cfg.ep),
}

local all_bras_axis = {}
for i, pos in ipairs(cfg.bras.axis.pos) do
  all_bras_axis[i] = translate(-cfg.bras.len/2+pos*cfg.base.width,0,0) * rotate(90,0,0) * ccylinder(cfg.axis.radius, 2*cfg.ep)
end
all_bras_axis = union(all_bras_axis)
bras = difference(bras, all_bras_axis)

local butee1 = difference{
    cube(cfg.ep, cfg.base.width, cfg.base.width),
    translate(0,cfg.ep,0) * 
        cube(2*cfg.ep, cfg.ep - 2*cfg.kerf, cfg.base.width/2),
      translate(0,-cfg.ep,0) * 
        cube(2*cfg.ep, cfg.ep - 2*cfg.kerf, cfg.base.width/2)
    }

local butee2 = difference{
    cube(cfg.ep, cfg.base.width, 1.5*cfg.base.width),
    translate(0,cfg.ep,0) * 
        cube(2*cfg.ep, cfg.ep - 2*cfg.kerf, cfg.base.width/2),
      translate(0,-cfg.ep,0) * 
        cube(2*cfg.ep, cfg.ep - 2*cfg.kerf, cfg.base.width/2)
    }

local all_mounted_pieces = union {
  translate(0, -cfg.ep, 0) * base_left,
  base_middle,
  translate(0, cfg.ep, 0) * base_right,
  translate(cfg.stabil.pos, 0, 0) * stabil,
  translate(-1.5*cfg.base.width,0,(cfg.axis.pos[1])*cfg.base.width) * rotate(0,-15,0) * bras,
  translate(cfg.stabil.pos+cfg.ep, 0, cfg.base.width/2) * butee2
}

local min_ecart =
  math.max(
    cfg.base.middle.len+cfg.base.width,
    cfg.base.height)
  + cfg.base.width
  + 6*cfg.kerf


local all_cutted = union{
  rotate(90,0,0) * base_left,
  translate(-cfg.base.width/2, -min_ecart,0) * rotate(90,0,180) * base_right,
  translate(2*cfg.base.width,-min_ecart/2,0) * rotate(90,0,90) * base_middle,
  translate(-4.5*cfg.base.width,-3*cfg.base.width,0) * rotate(0,90,0) * stabil,
  translate(0, cfg.base.width/2 + 3 * cfg.kerf, 0) * rotate(90,0,0) * bras,
  translate(-3.5*cfg.base.width+5*cfg.kerf,-3* cfg.base.width,0) * rotate(0,90,0) * butee1,
  translate(-3.5*cfg.base.width+5*cfg.kerf,-4* cfg.base.width-5*cfg.kerf,0) * rotate(0,90,0) * butee2,
}


local to_render

if (render_cut) then
  to_render = all_cutted
else
  to_render = all_mounted_pieces
end
emit(to_render)