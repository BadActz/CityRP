ATTACHMENT_SIGHT = 1
ATTACHMENT_BARREL = 2
ATTACHMENT_LASER = 3
ATTACHMENT_MAGAZINE = 4
ATTACHMENT_GRIP = 5

ATTACHMENT_SKIN = 99

local attItems = {}
attItems.att_rdot = {
    name = "Red Dot Sight",
    desc = "attRDotDesc",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "cw2_md_aimpoint",
        "cw2_md_microt1",
        "cw2_md_rmr",
    },
    icon = Material("atts/microt1"),
}

attItems.att_holo = {
    name = "Holographic Sight",
    desc = "attHoloDesc",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "cw2_md_kobra",
        "cw2_md_microt1",
        "cw2_md_eotech",
    },
    icon = Material("atts/eotech553"),
}

attItems.att_scope4 = {
    name = "4x Scope",
    desc = "attScope4Desc",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "cw2_md_acog",
        "cw2_md_schmidt_shortdot",
    },
    icon = Material("atts/acog"),
}

attItems.att_scope8 = {
    name = "8x Scope",
    desc = "attScope8Desc",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "cw2_md_pso1",
        "cw2_g3_scope",
    },
    icon = Material("atts/sg1scope"),
}

attItems.att_muzsup = {
    name = "Suppressor",
    desc = "attSupDesc",
    slot = ATTACHMENT_BARREL,
    attSearch = {
        "cw2_silencer",
    },
    icon = Material("atts/suppressor"),
}
attItems.att_exmag = {
    name = "Extended Mag",
    desc = "attEMagDesc",
    slot = ATTACHMENT_MAGAZINE,
    attSearch = {
        "cw2_ar15_60rndmag",
        "cw2_ak74_mag_rpk",
        "cw2_makarov_extmag",
        "cw2_mp5_30rndmag",
        "cw2_vss_20rnd",
    },
    icon = Material("atts/ar1560rndmag"),
}
attItems.att_foregrip = {
    name = "Foregrip",
    desc = "attForeDesc",
    slot = ATTACHMENT_GRIP,
    attSearch = {
        "cw2_foregrip",
    },
    icon = Material("atts/foregrip"),
}
attItems.att_laser = {
    name = "Laser Sight",
    desc = "attLaserDesc",
    slot = ATTACHMENT_LASER,
    attSearch = {
        "cw2_md_anpeq15",
    },
    icon = Material("atts/anpeq15"),
}


attItems.skin_quad = {
    name = "Quad Damage",
    desc = "skinDesc",
    slot = ATTACHMENT_SKIN,
    attSearch = {
        "skin_quad",
    },
    icon = Material("_skinpaint.png"),
}

local function attachment(item, data, combine)
    local client = item.player
    local char = client:getChar()
    local inv = char:getInv()
    local items = inv:getItems()

    local target = data

    -- This is the only way, ffagot
    for k, invItem in pairs(items) do
        if (data) then
            if (invItem:getID() == data) then
                target = invItem

                break
            end
        else
            if (invItem.isWeapon and invItem.isTFA) then
                target = invItem

                break
            end
        end
    end

    if (!target) then
        client:notifyLocalized("noWeapon")

        return false
    else
        local class = target.class
        local SWEP = weapons.Get(class)
        if (target.isTFA) then
            -- Insert Weapon Filter here if you just want to create weapon specific shit. 
            local weaponAttachments = SWEP.Attachments
            local mods = target:getData("atmod", {})
            
            if (weaponAttachments) then		                                
                -- Is the Weapon Slot Filled?
                if (mods[item.slot]) then
                    client:notifyLocalized("alreadyAttached")

                    return false
                end

                local targetAttachment

                for cat, info in pairs(weaponAttachments) do
                    if (targetAttachment) then break end
                    
                    if (info.atts) then
                        for index, att in pairs(info.atts) do
                            if (table.HasValue(item.attSearch, att)) then
                                targetAttachment = att

                                break
                            end
                        end
                    end
                end

                if (!targetAttachment) then
                    client:notifyLocalized("cantAttached")

                    return false
                end

                mods[item.slot] = {item.uniqueID, targetAttachment}
                target:setData("atmod", mods)

                local wepon = client:GetActiveWeapon()
                if not (IsValid(wepon) and wepon:GetClass() == target.class) then
                    for k, v in pairs(client:GetWeapons()) do
                        local wepClass = v:GetClass()
                        
                        if (wepClass == class) then
                            wepon = v
                        end
                    end
                end

                if (IsValid(wepon)) then
                    hook.Run("OnPlayerAttachment", item, wepon, targetAttachment, true)	
                else
                    hook.Run("OnPlayerAttachment", item, nil, targetAttachment, true)	
                end

                client:EmitSound("cw/holster4.wav")
                return true
            else
                client:notifyLocalized("notCW")

                return false
            end
        end
    end

    client:notifyLocalized("noWeapon")
    return false
end

for className, v in pairs(attItems) do
	local ITEM = nut.item.register(className, nil, nil, nil, true)
	ITEM.name = className
	ITEM.desc = v.desc
	ITEM.price = 2000
	ITEM.model = "models/Items/BoxSRounds.mdl"
	ITEM.width = 1
	ITEM.height = 1
	ITEM.isAttachment = true
	ITEM.category = "Attachments"
    ITEM.attSearch = v.attSearch
    ITEM.slot = v.slot
    ITEM.icon = v.icon

	ITEM.functions.use = {
         name = "Attach",
         tip = "useTip",
         icon = "icon16/wrench.png",
         isMulti = true,
         multiOptions = function(item, client)
             local targets = {}
             local char = client:getChar()
             
             if (char) then
                 local inv = char:getInv()

                 if (inv) then
                     local items = inv:getItems()

                     for k, v in pairs(items) do
                         if (v.isWeapon and v.isTFA) then
                             table.insert(targets, {
                                 name = L(v.name),
                                 data = v:getID(),
                             })
                         else
                             continue
                         end
                     end
                 end
             end

             return targets
        end,
        onCanRun = function(item)				
            return (!IsValid(item.entity))
        end,
        onRun = function(item, data)
             return attachment(item, data, false)
		end,
	}

    ITEM.functions.combine = {
        onCanRun = function(item, data)
            local targetItem = nut.item.instances[data]
            
            if (data and targetItem) then
                if (!IsValid(item.entity) and targetItem.isWeapon and targetItem.isTFA) then
                    return true
                else
                    return false
                end
            end
        end,
        onRun = function(item, data)
            return attachment(item, data, true)
        end,
    }
end

local conversionKits = {}
-- planned feature
-- make a package of weapon converter.
-- like MP5 to MP5SD (yeah seriously)