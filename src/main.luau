local game = require("./game")

local Color4, Enum, Udim = game.GetCommonElements()

function love.load()
    local width, height = 1100,800

    love.window.setMode(width, height, {
        fullscreen = false,
        borderless = false,
        resizable = true
    })

    love.mouse.setVisible(true)
end


function love.update(dt)

end

function love.draw()

end