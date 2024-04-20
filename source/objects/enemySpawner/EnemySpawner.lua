local playdate <const> = playdate
local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

local Cdf <const> = Cdf

class('EnemySpawner').extends()
local EnemySpawner <const> = EnemySpawner

local SPAWN_PAUSE_BASE_MS <const> = 5000
local BASE_ROCKET_THRUST <const> = 12

function EnemySpawner:init(cities)
	self.cities = cities
	self.uptime = 0
	self.started = false
	self.spawnTimer = nil
end

function EnemySpawner:start()
	self.uptime = 0
	self.started = true
	self.rockets = {}

	self:spawnAndSchedule()
end

function EnemySpawner:update()
	if not self.started then
		return
	end

	self.uptime += Cdf.deltaTime

	-- Iterate backwards so removal doesn't mess up position
	for i = #self.rockets, 1, -1 do
		local rocket = self.rockets[i]

		if rocket.y > 280 then
			rocket:remove()
			table.remove(self.rockets, i)
		end
	end
end

function EnemySpawner:spawnAndSchedule()
	-- Spawn one or more enemies
	self:_spawn()

	-- Schedule next spawn
	-- 0.8 - 1.2
	local rndAdjustPct = 0.8 + math.random() * 0.4
	local duration = SPAWN_PAUSE_BASE_MS * rndAdjustPct
	self.spawnTimer = playdate.timer.new(duration, function()
		self:spawnAndSchedule()
	end)
end

function EnemySpawner:_spawn()
	self:_spawnRocket()
end

function EnemySpawner:_spawnRocket()
	local x = math.random(-40, 440)
	local y = -20

	local targetCity = self.cities[math.random(1, #self.cities)]
	local targetX = targetCity.x
	local targetY = targetCity.y - 5

	local down = playdate.geometry.vector2D.new(0, -1)
	local vecToTarget = playdate.geometry.vector2D.new(targetX - x, targetY - y)
	vecToTarget:normalize()
	local angleToTarget = down:angleBetween(vecToTarget)

	local rocket = Rocket(x, y, angleToTarget)
	rocket.thrust = BASE_ROCKET_THRUST
	rocket:add()

	table.insert(self.rockets, rocket)
end

function EnemySpawner:finish()
	for i, rocket in ipairs(self.rockets) do
		rocket:remove()
	end
	self.rockets = {}

	self.started = false
	if self.spawnTimer ~= nil then
		self.spawnTimer:remove()
		self.spawnTimer = nil
	end
end
