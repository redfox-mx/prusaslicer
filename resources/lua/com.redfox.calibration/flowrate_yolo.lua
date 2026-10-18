info = {
    id = 'com.redfox.calibration.flowrate.yolo',
    type = 'project.plugin',
    title = 'Flow Ratio (YOLO)',
    menu = 'Calibration/Flow Ratio/YOLO',
    params = {}
}

function execute()
    local samples = {
        5, 4,  3,  2,
        1, 0, -1, -2,
          -3, -4, -5
    }

    local Flowrate = require('flowrate')
    local test = Flowrate:new('assets/flowrate_yolo')
    local bed = api.project:current_bed()
    local material_cfg = bed:material_presets(0)
    local extrusion_multiplier = material_cfg:value('extrusion_multiplier')

    test:generate(samples, function (value)
        local new_extrusion_multiplier = (extrusion_multiplier + (value / 100))
        return (new_extrusion_multiplier / extrusion_multiplier)
    end)
end