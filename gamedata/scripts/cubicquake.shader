edit
{
	program defaultsprite	
	diffusemap edit.png
	
	bemode depthonly
	{
		program depthonly
		{
			map $diffuse
			depthwrite
			colormask			
		}
	}
	{
		map $diffuse
		depthwrite		
		rgbgen vertex
		alphagen vertex
		blendfunc blend
		depthfunc equals
	}
}

dirt_top
{
	program defaultsprite	
	diffusemap ground1_6.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

dirt_side
{
	program defaultsprite	
	diffusemap uwall1_2.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

dirt_bottom
{
	program defaultsprite	
	diffusemap uwall1_2.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

city4_6_top
{
	program defaultsprite	
	diffusemap city4_6.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

city4_6_side
{
	program defaultsprite	
	diffusemap city4_6.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

city4_6_bottom
{
	program defaultsprite	
	diffusemap city4_6.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

bricka2_top
{
	program defaultsprite	
	diffusemap bricka2_2.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

bricka2_side
{
	program defaultsprite	
	diffusemap bricka2_2.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

bricka2_bottom
{
	program defaultsprite	
	diffusemap bricka2_1.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

mmetal1_2_top
{
	program defaultsprite	
	diffusemap mmetal1_2.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

mmetal1_2_side
{
	program defaultsprite	
	diffusemap mmetal1_2.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

mmetal1_2_bottom
{
	program defaultsprite	
	diffusemap mmetal1_2.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

exit02_2_top
{
	program defaultsprite	
	diffusemap exit02_2.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

exit02_2_side
{
	program defaultsprite	
	diffusemap exit02_2.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

exit02_2_bottom
{
	program defaultsprite	
	diffusemap exit02_2.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

metal4_top
{
	program defaultsprite	
	diffusemap metal4_5.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

metal4_side
{
	program defaultsprite	
	diffusemap metal4_2.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

metal4_bottom
{
	program defaultsprite	
	diffusemap metal4_5.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

metal5_3_top
{
	program defaultsprite	
	diffusemap metal5_3.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

metal5_3_side
{
	program defaultsprite	
	diffusemap metal5_3.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

metal5_3_bottom
{
	program defaultsprite	
	diffusemap metal5_3.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

cop_top
{
	program defaultsprite	
	diffusemap cop3_1.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

cop_side
{
	program defaultsprite	
	diffusemap cop2_6.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

cop_bottom
{
	program defaultsprite	
	diffusemap cop2_3.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

cop1_3_top
{
	program defaultsprite
	diffusemap cop1_3.png
	
	{
		map $diffuse
		rgbgen vertex		
	}
}

cop1_3_side
{
	program defaultsprite
	diffusemap cop1_3.png
	
	{
		map $diffuse
		rgbgen vertex		
	}
}

cop1_3_bottom
{
	program defaultsprite
	diffusemap cop1_3.png
	
	{
		map $diffuse
		rgbgen vertex		
	}
}

wizwood1_3_top
{
	program defaultsprite	
	diffusemap wizwood1_3.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

wizwood1_3_side
{
	program defaultsprite	
	diffusemap wizwood1_3.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

wizwood1_3_bottom
{
	program defaultsprite	
	diffusemap wizwood1_3.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

bluestone_top
{
	program defaultsprite	
	diffusemap wall9_8.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

bluestone_side
{
	program defaultsprite	
	diffusemap stone1_3.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

bluestone_bottom
{
	program defaultsprite	
	diffusemap wall9_8.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

wiz1_1_top
{
	program defaultsprite	
	diffusemap wiz1_1.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

wiz1_1_side
{
	program defaultsprite	
	diffusemap wiz1_1.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

wiz1_1_bottom
{
	program defaultsprite	
	diffusemap wiz1_1.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

m5_top
{
	program defaultsprite	
	diffusemap m5_3.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

m5_side
{
	program defaultsprite	
	diffusemap m5_5.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}

m5_bottom
{
	program defaultsprite	
	diffusemap m5_8.png
	
	{
		map $diffuse
		rgbgen vertex
	}
}