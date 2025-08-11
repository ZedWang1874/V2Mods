return {
	mod_description = {
		en = "Visualizes map boundaries, building edges, and invisible walls with colored lines. Use commands to toggle features.",
		zh = "可视化地图边界、建筑边缘和空气墙，用彩色线条标记。使用命令切换功能。",
	},
	
	-- Setting options
	enable_building_edges = {
		en = "Show Building Edges",
		zh = "显示建筑边缘",
	},
	enable_airwalls = {
		en = "Show Air Walls", 
		zh = "显示空气墙",
	},
	enable_map_boundaries = {
		en = "Show Map Boundaries",
		zh = "显示地图边界",
	},
	scan_distance = {
		en = "Scan Distance",
		zh = "扫描距离",
	},
	line_thickness = {
		en = "Line Thickness",
		zh = "线条粗细",
	},
	auto_rescan = {
		en = "Auto Rescan on Level Load",
		zh = "关卡加载时自动重扫",
	},
	
	-- Command descriptions
	toggle_description = {
		en = "Toggle border visualization on/off",
		zh = "开关边界可视化",
	},
	rescan_description = {
		en = "Rescan current level for boundaries",
		zh = "重新扫描当前关卡边界",
	},
	debug_description = {
		en = "Toggle debug mode",
		zh = "切换调试模式",
	},
	
	-- Messages
	enabled_message = {
		en = "Border Check: Enabled - Scanning boundaries...",
		zh = "边界检查：已启用 - 正在扫描边界...",
	},
	disabled_message = {
		en = "Border Check: Disabled",
		zh = "边界检查：已禁用",
	},
	rescanning_message = {
		en = "Border Check: Rescanning level...",
		zh = "边界检查：重新扫描关卡中...",
	},
	debug_mode = {
		en = "Debug mode: ",
		zh = "调试模式：",
	},
}
