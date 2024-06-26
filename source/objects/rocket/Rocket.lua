local playdate <const> = playdate
local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

local rocketImageTable <const> = gfx.imagetable.new("objects/rocket/rocket")
local rocketExhaustImageTable <const> = gfx.imagetable.new("objects/rocket/rocket-exhaust")

class('Rocket').extends(gfx.sprite)
local Rocket <const> = Rocket
Rocket:implements(StaticEventEmitter)

function Rocket:init(x, y, angle)
	Rocket.super.init(self)

	self.x = x
	self.y = y
	self:setAngle(angle)
	self.thrust = 0

	self.exhaust = RocketExhaust(self)
	self.exhaust:add()

	self:moveTo(x, y)
	self:_setImage()
	self:setCollideRect(0, 0, self:getSize())
end

function Rocket:update()
	if self.thrust == 0 then
		self.exhaust:setVisible(false)
	else
		self.exhaust:setVisible(true)

		-- Apply thrust
		local deltaX = self.thrust * Cdf.deltaTime * self.cos
		local deltaY = self.thrust * Cdf.deltaTime * self.sin

		self:moveBy(deltaX, deltaY)

		self:_updateCollision()
	end

	self:_setImage()
end

function Rocket:_updateCollision()
	for i, otherSprite in ipairs(self:overlappingSprites()) do
		if otherSprite:isa(Explosion) then
			local dist = playdate.geometry.distanceToPoint(self.x, self.y, otherSprite.x, otherSprite.y)

			if dist <= otherSprite.radius then
				self:explode()
				Rocket._staticEmit('explodedByExplosion', { rocket = self })
				return
			end
		end

		if not self:alphaCollision(otherSprite) then
			goto continue
		end

		self:explode()

		if otherSprite:isa(Rocket) then
			--  This only makes sense becaues CPUs don't collide with each other
			Rocket._staticEmit('cpuDestroyedByPlayer', { rocket = self, otherRocket = otherSprite })

			otherSprite:remove()
		elseif otherSprite:isa(City) then
			timer.performAfterDelay(250, function()
				otherSprite:destroy()
			end)
		end

		::continue::
	end
end

function Rocket:_setImage()
	local newImage = rocketImageTable:getImage(
		(roundToNearest(self.angle, 15) % 360) / 15 + 1
	)

	if newImage ~= self.oldImage then
		self:setImage(newImage)
		self.oldImage = newImage
	end
end

function Rocket:changeAngle(delta)
	self:setAngle((self.angle + delta) % 360)
end

function Rocket:setAngle(newAngle)
	self.angle = newAngle % 360

	local radAngle = math.rad(self.angle - 90)
	self.cos = math.cos(radAngle)
	self.sin = math.sin(radAngle)
end

function Rocket:explode()
	local explosion = Explosion(self.x, self.y)
	explosion:add()

	self:remove()
end

function Rocket:remove()
	Rocket.super.remove(self)
	Rocket._staticEmit('remove', { rocket = self })
	self.exhaust:remove()
end
