Config = {}

Config.spawnLocation = {
    position = vector3(758.93, -3195.42, 5.08),
    blipType = 229,
    blipColor = 1,
    label = 'Car Robbery'
}

Config.coolDown = 1 --cooldown time in minutes
Config.copsRequired = 0
Config.copTimerIntervel = 5 --time intervel b/w each cop notification in seconds
Config.timer = 60 --time to get back in car if player left car in seconds
Config.CarSellingTime = 5 --time taking to sell car in seconds

Config.Delivery = {
    [1] = {
        position  = vector3(1310.56, 4326.33, 38.08),
        heading   = 340.1,
        blipColor = 1,
        blipType  = 1,
        label     = 'Delivery location',
        Payment   = 18000,
        Cars      = { 'zentorno', 't20', 'reaper', 'italigtb', 'pfister811' },
    },

    [2] = {
        position  = vector3(3800.39, 4453.41, 4.59),
        heading   = 52.67,
        blipColor = 1,
        blipType  = 1,
        label     = 'Delivery location',
        Payment   = 20000,
        Cars      = { 'sultanrs', 'osiris', 'cyclone', 'ruston', 'turismor' },
    },

    [3] = {
        position  = vector3(-198.2, 6557.08, 11.04),
        heading   = 316.83,
        blipColor = 1,
        blipType  = 1,
        label     = 'Delivery location',
        Payment   = 25000,
        Cars      = { 'entityxf', 'sheava', 'gp1', 'vagner', 'neon' },
    },

    [4] = {
        position  = vector3(-2338.65, 4132.09, 25.78),
        heading   = 70.8,
        blipColor = 1,
        blipType  = 1,
        label     = 'Delivery location',
        Payment   = 19500,
        Cars      = { 'nero', 'seven70', 'tempesta', 'xa21', 'raiden' },
    },

    [5] = {
        position  = vector3(1549.97, 3529.13, 35.56),
        heading   = 120.99,
        blipColor = 1,
        blipType  = 1,
        label     = 'Delivery location',
        Payment   = 16000,
        Cars      = { 'specter', 'comet5', 'nightshade', 'sc1', 'banshee2' },
    },
}


-- Config.vehicleSpawnPoint = {
--     Pos  = { x = 767.71, y = -3195.20, z = 5.50, alpha = 0.00 }, --alpha is the orientation of the car
--     Size = { x = 3.0, y = 3.0, z = 1.0 },
--     Type = -1,
-- }
Config.vehicleSpawnPoint = vector4(770.03, -3195.83, 5.9, 349.78)

Config.carSeller = {
    carSellerPos = vector4(757.76, -3195.32, 5.05, 280.93),
    carSellerModel = "s_m_y_construct_01",
    carSellerHash = 0xD7DA9E99,
    targetZone = vector3(757.76, -3195.32, 5.05),
    targetHeading = 280.93,
    minZ = 3.05,
    maxZ = 7.05,
}
