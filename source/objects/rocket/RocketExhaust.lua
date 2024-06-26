local playdate <const> = playdate
local gfx <const> = playdate.graphics

local rocketExhaustImageTable <const> = gfx.imagetable.new("objects/rocket/rocket-exhaust")

class('RocketExhaust').extends(gfx.sprite)
local RocketExhaust <const> = RocketExhaust

function RocketExhaust:init(rocket)
	RocketExhaust.super.init(self)

	self.rocket = rocket

	self.animLoop = gfx.animation.loop.new(80, rocketExhaustImageTable)
	self:setImage(self.animLoop:image())

	self:setCenter(0.5, 0)
end

function RocketExhaust:update()
	local x = self.rocket.x - (5 * self.rocket.cos)
	local y = self.rocket.y - (5 * self.rocket.sin)

	self:moveTo(x, y)
	self:setRotation(self.rocket.angle)

	local newImage = self.animLoop:image()
	if newImage ~= self.oldImage then
		self:setImage(newImage)
		self.oldImage = newImage
	end
end
