smoothness = 80;

pcbDiameter = 60.0;
pcbHeight = 21.0;

bodyThickness = 3.0;
bodyDiameter = pcbDiameter + 2*bodyThickness + 1.0;
bodyLength = pcbHeight + bodyThickness + 2.0;

mountHoleDiameter = 3.5;
mountHoleOffset = 25.0;

flangeLength = 20.0;
flangeWidth = 20.0;
flangeThickness = 3.0;
flangeHoleDiameter = 3.0;
flangeHoleOffset = 7;

legLength = 70;
legGussetWidth = 8.0;
legGussetLength = legLength + 10;
legGussetThickness = flangeThickness;
bottomOpeningDiameter = bodyDiameter - 8;

lidarMount();

module lidarMount() {
	union() {
		difference() {
			lidarBody();
			lidarMountHoles();
		}
		lidarFlanges();
	}
}

module lidarBody() {
	translate([0,0,0])
	rotate([0,0,0])
	difference() {
		cylinder(d=bodyDiameter, h=bodyLength, $fn=smoothness);
		cylinder(d=bodyDiameter-bodyThickness, h=bodyLength-bodyThickness, $fn=smoothness);
	}
}

module lidarMountHoles() {
	translate([mountHoleOffset,0,bodyLength-bodyThickness])
	rotate([0,0,0])
		cylinder(d=mountHoleDiameter, h=bodyThickness, $fn=smoothness);

	translate([-mountHoleOffset,0,bodyLength-bodyThickness])
	rotate([0,0,0])
		cylinder(d=mountHoleDiameter, h=bodyThickness, $fn=smoothness);

	translate([0,mountHoleOffset,bodyLength-bodyThickness])
	rotate([0,0,0])
		cylinder(d=mountHoleDiameter, h=bodyThickness, $fn=smoothness);

	translate([0,-mountHoleOffset,bodyLength-bodyThickness])
	rotate([0,0,0])
		cylinder(d=mountHoleDiameter, h=bodyThickness, $fn=smoothness);
}

module lidarFlanges() {
	rotate([0,0,0])
		lidarLeg();
	rotate([0,0,60])
		lidarLeg();
//	rotate([0,0,120])
//		lidarLeg();
	rotate([0,0,180])
		lidarLeg();
	rotate([0,0,240])
		lidarLeg();
//	rotate([0,0,300])
//		lidarLeg();
}

module lidarLeg() {
	union() {
		translate([0,0,0])
		lidarFlange();
	}
}

module lidarFlange() {
	translate([0,0,-legLength])
	union() {
		difference() {
			union() {
				// Rounded End of Flange
				translate([bodyDiameter/2+flangeLength-flangeWidth/2,0,0])
					cylinder(d=flangeWidth, h=flangeThickness, $fn=smoothness);
				// Flange
				difference() {
					translate([bodyDiameter/2-flangeLength-flangeWidth/2,-flangeWidth/2,0])
						cube([flangeLength*2, flangeWidth, flangeThickness]);
					cylinder(d=bodyDiameter-bodyThickness, h=flangeThickness, $fn=smoothness);
				}
			}
			// Flange Mounting Hole
			translate([bodyDiameter/2+flangeLength-flangeHoleOffset,0,0])
				cylinder(d=flangeHoleDiameter, h=flangeThickness, $fn=smoothness);
			//cylinder(d=bodyDiameter, h=flangeThickness+20, $fn=smoothness);
		}
		intersection() {
			difference() {
				// Leg
				cylinder(d=bodyDiameter, h=legLength, $fn=smoothness);
				cylinder(d=bodyDiameter-bodyThickness, h=legLength, $fn=smoothness);
			}
			translate([0,-flangeWidth/2,0])
				cube([bodyDiameter, flangeWidth, legLength]);
		}
		rotate([90,0,0])
		translate([bodyDiameter/2,0,-bodyThickness/2])
		Right_Angled_Triangle(a=legGussetLength, b=legGussetWidth, height=legGussetThickness, centerXYZ=[false,false,false]);
	}
}

module Triangle(
			a, b, angle, height=1, heights=undef,
			center=undef, centerXYZ=[false,false,false])
{
	// Calculate Heights at each point
	heightAB = ((heights==undef) ? height : heights[0])/2;
	heightBC = ((heights==undef) ? height : heights[1])/2;
	heightCA = ((heights==undef) ? height : heights[2])/2;
	centerZ = (center || (center==undef && centerXYZ[2]))?0:max(heightAB,heightBC,heightCA);

	// Calculate Offsets for centering
	offsetX = (center || (center==undef && centerXYZ[0]))?((cos(angle)*a)+b)/3:0;
	offsetY = (center || (center==undef && centerXYZ[1]))?(sin(angle)*a)/3:0;

	pointAB1 = [-offsetX,-offsetY, centerZ-heightAB];
	pointAB2 = [-offsetX,-offsetY, centerZ+heightAB];
	pointBC1 = [b-offsetX,-offsetY, centerZ-heightBC];
	pointBC2 = [b-offsetX,-offsetY, centerZ+heightBC];
	pointCA1 = [(cos(angle)*a)-offsetX,(sin(angle)*a)-offsetY, centerZ-heightCA];
	pointCA2 = [(cos(angle)*a)-offsetX,(sin(angle)*a)-offsetY, centerZ+heightCA];

	polyhedron(
		points=[	pointAB1, pointBC1, pointCA1,
					pointAB2, pointBC2, pointCA2 ],
		faces=[
			[0, 1, 2],
			[3, 5, 4],
			[0, 3, 1],
			[1, 3, 4],
			[1, 4, 2],
			[2, 4, 5],
			[2, 5, 0],
			[0, 5, 3] ] );
}

module Right_Angled_Triangle(
			a, b, height=1, heights=undef,
			center=undef, centerXYZ=[false, false, false])
{
	Triangle(a=a, b=b, angle=90, height=height, heights=heights,
				center=center, centerXYZ=centerXYZ);
}
