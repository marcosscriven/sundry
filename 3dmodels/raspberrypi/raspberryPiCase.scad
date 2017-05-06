module aaBattery(length, diameter) 
{
	length = 49; 
	diameter = 14;
	nippleHeight = 2;
	nippleDiameter = 5;

    union()
	{
		cylinder(h=length, r=diameter/2, $fs=1);
		translate ([0,0,length]) cylinder(h=nippleHeight, r=nippleDiameter/2, $fs=1);
	}
}

aaBattery();
//translate([0, 0, 51]) aaBattery();

caseLength = 120;
caseHeight = 35;
cube();


