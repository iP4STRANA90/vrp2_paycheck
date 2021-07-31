--[[
    FiveM Scripts
    Copyright C 2018  Sighmir

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    at your option any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

-- this module make paycheck and bill to pay for users who have group permission
--[[
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

local cfg = module("vrp_paycheck", "cfg/paycheck")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_paycheck")
vRPpcC = Tunnel.getInterface("vRP_paycheck","vRP_paycheck")
]]--

local lang = vRP.lang
local Luang = module("vrp", "lib/Luang")

local cfg = module("vrp_paycheck", "cfg/paycheck")

local paycheck = class("paycheck", vRP.Extension)

function paycheck:__construct()
  vRP.Extension.__construct(self)
  -- task: mission
  local function paycheck_giver()
    SetTimeout(60000*cfg.minutes_paycheck,paycheck_giver)
    self:paycheck_giver()
  end
  async(function()
    paycheck_giver()
  end)

  -- task: mission
  local function paycheck_taker()
    SetTimeout(60000*cfg.minutes_bill,paycheck_taker)
    self:paycheck_taker()
  end
  async(function()
    paycheck_taker()
  end)
end

function paycheck:paycheck_giver(user)
  for k,v in pairs(cfg.paycheck) do
    local users = vRP.EXT.Group:getUsersByPermission(k)
    for _,user in pairs(users) do
      if cfg.bank then
        user:giveBank(v)
      else
        user:giveWallet(v)
      end
      vRP.EXT.Base.remote._notifyPicture(user.source,cfg.paycheck_picture, 9, cfg.paycheck_title_picture, false, cfg.message_paycheck..v..cfg.post)
    end	
  end
end

function paycheck:paycheck_taker(user)
  for k,v in pairs(cfg.bill) do
    local users = vRP.EXT.Group:getUsersByPermission(k)
    for _,user in pairs(users) do
      if cfg.bank then
        user:giveBank(v)
      else
        user:giveWallet(v)
      end
      vRP.EXT.Base.remote._notifyPicture(user.source,cfg.bill_picture, 9, cfg.bill_title_picture, false, cfg.message_bill..v..cfg.post)
    end	
  end
end

vRP:registerExtension(paycheck)
