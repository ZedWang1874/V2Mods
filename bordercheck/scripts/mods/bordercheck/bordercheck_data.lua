local mod = get_mod("bordercheck")

return {
	name = "Border Check",
	description = mod:localize("mod_description"),
	is_togglable = true,
	
	options = {
		widgets = {
			{
				setting_id = "enable_building_edges",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "enable_airwalls",
				type = "checkbox", 
				default_value = true,
			},
			{
				setting_id = "enable_map_boundaries",
				type = "checkbox",
				default_value = true,
			},
			{
				setting_id = "scan_distance",
				type = "numeric",
				default_value = 50,
				range = {10, 100},
			},
			{
				setting_id = "line_thickness",
				type = "numeric",
				default_value = 1,
				range = {0.5, 5},
			},
			{
				setting_id = "auto_rescan",
				type = "checkbox",
				default_value = true,
			}
		}
	}
}
