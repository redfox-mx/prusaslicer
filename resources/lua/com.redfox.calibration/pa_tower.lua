info = {
    id = 'com.redfox.calibration.pressureadvance.tower',
    type = 'project.plugin',
    title = 'Pressure Advance Tower',
    menu = 'Calibration/Pressure/PA Tower',
    params = {
        {name = "pa_start", label = "Start PA", type = "string", default = "0"},
        {name = "pa_end", label = "End PA", type = "string", default = "0.08"},
        {name = "pa_step", label = "PA step", type = "string", default = "0.002"},
        {name = "step_depth", label = "Step Depth  [mm]", type = "int", default = 1},
    }
}

local function parse_number(s, default)
    local v = tonumber(s)
    if v == nil then return default end
    return v
end

function execute(opts)
    local bed = api.project:current_bed()
    local mat_cfg = bed:material_presets(0)
    mat_cfg:set('cooling', false)

    local pa_start = parse_number(opts.pa_start, 0)
    local pa_end = parse_number(opts.pa_end, 0.08)
    local pa_step = parse_number(opts.pa_step, 0.002)
    local step_depth = opts.step_depth

    local n_steps = math.ceil((pa_end - pa_start) / pa_step)
    local height = n_steps * step_depth
    local tower_mesh = api.emboss_svg("assets/pressure_advance/pa_tower.svg", height)


    api.project:insert_layer_custom_gcode(bed, 0, 'M572 S' .. pa_start)
    for step = 1, n_steps do
        local z_layer = step * step_depth
        local s_value = pa_start + (step * pa_step)
        api.project:insert_layer_custom_gcode(bed, z_layer, 'M572 S' .. s_value .. ' ; PA VALUE: ' .. s_value)
    end

    api.project:add_object({
        mesh=tower_mesh,
        object_params = {
            seam_position = 'rear',
        },
        params={
            fill_density="0%",
            top_solid_layers=0,
            bottom_solid_layers=0,
            perimeters=2,
        }
    })
end