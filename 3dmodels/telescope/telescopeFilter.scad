// Circle resolution - 1 degree is usually smooth enough, but use 10 for faster rendering
$fa = 10;

// Main parameter
objectiveDiameter = 96;
objectiveRadius = objectiveDiameter/2;

thickness = 2;
depth = 22.5;
rimWidth = 10;
rimRadius = objectiveRadius + rimWidth;
rimRidge = 2;

// The gap between parts - smaller will give you a tighter fit, but risks not being able to fit at all.
errorMargin = 0.4;

// This is probably in the standard library
module ring(inner, outer, height)
{
    cutHeight = height + 2;

	difference() 
	{
  		cylinder(h=height, r=outer);
  		translate ([0,0,-1]) cylinder(h=cutHeight, r=inner);
	}
}



module lens() {
	ring(inner=objectiveRadius-rimRidge, outer=rimRadius, height=thickness);
	translate ([0,0,thickness]) ring(inner=objectiveRadius, outer=objectiveRadius+thickness, height=depth);
    translate ([0,0,thickness+depth]) ring(inner=objectiveRadius-0.4, outer=objectiveRadius+thickness, height=4);
}

// The lens attachment - the lens module with bits cut out. Makes it a lot easier to attach than a solid ring
module lensAttachment() {
  difference() {
	lens();	
	for (i = [0:5]) {
		translate([sin(6+360*i/6)*objectiveRadius, cos(6+360*i/6)*objectiveRadius, 9 ])
		cylinder(h = depth+10, r=10.5);
	}
  }
}

lensAttachment();


// The filter cover
module filterCover() {
   	ring(inner=objectiveRadius-rimRidge, outer=rimRadius+thickness+errorMargin, height=thickness);
	translate([0,0,thickness]) ring(inner=rimRadius+errorMargin, outer=rimRadius+thickness+errorMargin, height=thickness);
}

//filterCover();






