use <deps.link/erhannisScad/misc.scad>
use <deps.link/scadFluidics/common.scad>
use <deps.link/BOSL/nema_steppers.scad>
use <deps.link/BOSL/joiners.scad>
use <deps.link/BOSL/shapes.scad>
use <deps.link/getriebe/Getriebe.scad>

$fn=120;
BIG = 1000;
EPS = 1e-8;


INTERVAL = 30; //TODO Eh


ROD_D = 5;
BD = 28.3; // Blade diam
BT = 0.32; // Blade thickness

CUT_DEPTH = 8;
RD = BD - CUT_DEPTH; // Roller diam
GN = 2; // Gap number = blade thicknesses
NUT_DEPTH = 7;
NUT_D = 10;

// Print one less than stack size (you don't want a blade at the edge of the stack)
module spacerCut() {
  difference() {
    cylinder(d=RD,h=INTERVAL-BT);
    cylinder(d=ROD_D,h=BIG,center=true);
  }
}

// Print one more than stack size (to replace the spacerCut at the edge of the stack)
module spacerGap() {
  difference() {
    union() {
      cylinder(d=RD,h=INTERVAL-GN*BT);
      up(INTERVAL-GN*BT) cylinder(d=RD-CUT_DEPTH,h=GN*BT);
    }
    cylinder(d=ROD_D,h=BIG,center=true);
  }
}

// Print two; place them on opposite ends of the stacks to shift the blades to the center of the gaps
module spacerThin() {
  difference() {
    cylinder(d=RD,h=(0.5*GN*BT-0.5*BT)/2);
    cylinder(d=ROD_D,h=BIG,center=true);
  }
}

// Print 2 plain and 2 mirrored
module gear() { //TODO Taper bottom face?
  teeth = 25;
  height = 15;
  margin = 1;
  geardims = pfeilrad_dims(modul=1, zahnzahl=teeth, breite=height, bohrung=ROD_D, eingriffswinkel=20, schraegungswinkel=30, optimiert=false);
  //geardims[1];
  pfeilrad(modul=1*(RD/geardims[1]), zahnzahl=teeth, breite=height, bohrung=ROD_D, eingriffswinkel=20, schraegungswinkel=30, optimiert=false);
  //pfeilrad(modul=1, zahnzahl=teeth, breite=15, bohrung=ROD_D, eingriffswinkel=20, schraegungswinkel=30, optimiert=false);
  geardims2 = pfeilrad_dims(modul=1*(RD/geardims[1]), zahnzahl=teeth, breite=15, bohrung=ROD_D, eingriffswinkel=20, schraegungswinkel=30, optimiert=false);
  difference() {
    up(height) cylinder(d=geardims2[2],h=margin);
    cylinder(d=ROD_D,h=BIG,center=true);
  }
}

TDD = (RD/2 - NUT_DEPTH)*0.75;
// Print 1 plain and 1 mirrored
module bracket() {
  //cmirror([1,0,0]) right(RD/2) {rotate([90,0,0]) cylinder(d=ROD_D,h=BIG,center=true);}
  difference() {
    cube([BD*2.5,RD/2,BD*1.5],center=true);
    cmirror([1,0,0]) right(RD/2) {
      translate([0,0,BIG/2]) cube([ROD_D,BIG,BIG],center=true);
      rotate([90,0,0]) cylinder(d=ROD_D,h=BIG,center=true);
      translate([0,BIG/2+RD/4-NUT_DEPTH,BIG/2]) cube([NUT_D,BIG,BIG],center=true);
      forward(-BIG/2-RD/4+NUT_DEPTH) rotate([90,0,0]) cylinder(d=NUT_D,h=BIG,center=true);
    }
    translate([0,-RD/4+(RD/2 - NUT_DEPTH)/2,TDD/2+ROD_D/2]) rotate([0,0,90]) teardrop(d=TDD,h=BIG);
  }
}
// Print 2
module bracketLock() {
  cylinder(d=TDD,h=BD*2.5);
}

INTERVAL_COUNT = 8;
// Print 2
module bracer() {
  rotate([90,0,0]) translate([0,RD,0]) difference() {
    translate([0,-RD,0]) linear_extrude(INTERVAL*INTERVAL_COUNT) triangle(height=BD*0.9);
    cylinder(d=RD,h=BIG,center=true);
    for (i = [0:INTERVAL_COUNT]) {
      up(i*INTERVAL) cylinder(d=BD+2,h=2*GN*BT,center=true);
    }
  }
}

/*
down(0.25*GN*BT) right(RD) spacerCut();
up(INTERVAL+5) right(RD) spacerThin();
up(0.25*GN*BT) spacerGap();
down(5) spacerThin();
*/


// Print the following things

//spacerCut();
//spacerGap();
//spacerThin();
//gear();
//mirror([1,0,0]) gear();

//bracket();
//mirror([0,1,0]) bracket();
//bracketLock();

//bracer();