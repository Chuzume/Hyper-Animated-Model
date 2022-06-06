-- the "im too dumb to find them so I made my own" section
    function lenth3(vector)
        return math.sqrt(math.pow((vector.x),2)+math.pow((vector.y),2)+math.pow((vector.x),2))
    end

    function lenth2(vector)
        return math.sqrt(math.pow((vector.x),2)+math.pow((vector.y),2))
    end

    function dotp(value)
        if value ~= 0 then
            return value/math.abs(value)
        end
        return 0
    end

-- Lerped properties by Manuel_#2867
-- Uses lerp to smooth out animations automatically, so you dont have to. Example:
-- local cube = new_lerped_property(model.path.to.cube)
-- then you can just set rotation, position, etc, inside tick() and it will automatically be smooth

do
    function lerp(a, b, x)
        return a + (b - a) * x
    end
    
    function lerp_3d(a, b, x)
        return {lerp(a[1],b[1],x),lerp(a[2],b[2],x),lerp(a[3],b[3],x)}
    end

    function new_lerped_property(part)
        local ret = {}
        ret.prev_pos = {0,0,0}
        ret.curr_pos = {0,0,0}
        ret.enab_pos = false
        ret.prev_rot = {0,0,0}
        ret.curr_rot = {0,0,0}
        ret.enab_rot = false
        ret.prev_sca = {1,1,1}
        ret.curr_sca = {1,1,1}
        ret.enab_sca = false
        ret.prev_uv = {0,0,0}
        ret.curr_uv = {0,0,0}
        ret.enab_uv = false
        ret.prev_col = {1,1,1}
        ret.curr_col = {1,1,1}
        ret.enab_col = false
        ret.prev_opa = 1
        ret.curr_opa = 1
        ret.enab_opa = false
        function tick()
            ret.prev_pos = ret.curr_pos
            ret.prev_rot = ret.curr_rot
            ret.prev_sca = ret.curr_sca
            ret.prev_uv = ret.curr_uv
            ret.prev_col = ret.curr_col
            ret.prev_opa = ret.curr_opa
        end
        function render(delta)
            if ret.enab_pos then part.setPos(lerp_3d(ret.prev_pos,ret.curr_pos,delta)) end
            if ret.enab_rot then part.setRot(lerp_3d(ret.prev_rot,ret.curr_rot,delta)) end
            if ret.enab_sca then part.setScale(lerp_3d(ret.prev_sca,ret.curr_sca,delta)) end
            if ret.enab_uv then part.setUV(lerp_3d(ret.prev_uv,ret.curr_uv,delta)) end
            if ret.enab_col then part.setColor(lerp_3d(ret.prev_col,ret.curr_col,delta)) end
            if ret.enab_opa then part.setOpacity(lerp(ret.prev_opa,ret.curr_opa,delta)) end
        end
        local function setPos(pos)
            ret.enab_pos = true
            ret.curr_pos = pos
        end
        local function setRot(rot)
            ret.enab_rot = true
            ret.curr_rot = rot
        end
        local function setScale(scale)
            ret.enab_sca = true
            ret.curr_sca = scale
        end
        local function setUV(uv)
            ret.enab_uv = true
            ret.curr_uv = uv
        end
        local function setColor(color)
            ret.enab_col = true
            ret.curr_col = color
        end
        local function setOpacity(opacity)
            ret.enab_opa = true
            ret.curr_opa = opacity
        end
        ret.setPos = setPos
        ret.setRot = setRot
        ret.setScale = setScale
        ret.setUV = setUV
        ret.setColor = setColor
        ret.setOpacity = setOpacity
        return ret
    end
end

-- Define body parts
    head = new_lerped_property(model.Body.MIMIC_HEAD_MAIN.offset)

    body = new_lerped_property(model.Body)

    leftarm = new_lerped_property(model.Body.LeftArm)
    rightarm = new_lerped_property(model.Body.RightArm)

    lefthand = new_lerped_property(model.Body.LeftArm.LeftHand)
    righthand = new_lerped_property(model.Body.RightArm.RightHand)

    leftleg = new_lerped_property(model.Body.LeftLeg)
    rightleg = new_lerped_property(model.Body.RightLeg)

    leftfoot = new_lerped_property(model.Body.LeftLeg.LeftFoot)
    rightfoot = new_lerped_property(model.Body.RightLeg.RightFoot)

--========================================================--
--GNs animated player by GNamimates
--version 1.1
--adds cool animations using the one and only figura mod!
--========================================================--

-- Define...somethings
    PI = 3.14159

    LastPos2 = vectors.of({0,0,0})
    Pos2 = vectors.of({0,0,0})

    function tick()
        LastPos2 = Pos2
        Pos2 = vectors.of({math.sin(world.getTime()*0.2)*20,0,0})
    end


-- Define key
    attackKey = keybind.getRegisteredKeybind("key.attack")
    interactKey = keybind.getRegisteredKeybind("key.use")
    dropKey = keybind.getRegisteredKeybind("key.drop")

-- Define pings
    network.registerPing("LeftClickPunch")
    network.registerPing("LeftClickSword")
    network.registerPing("LeftClickUse")
    network.registerPing("LeftClickPickaxe")
    network.registerPing("RightClick")
    network.registerPing("Drop")

--======CONFIG=======--
-- I don suggest changing this one, because it can break the punching animation
    stiffness = 0.7 --the lower the value is, the smoother the blending between animation tracks is

-- Pickaxe type swing items
    ToolSwing = {"shovel","hoe","pickaxe","shield"}

-- No swing items
    NoSwing = {"air"}

-- Init
function player_init()

    -- Define variables
        lastgrounded = false--used to simulate AI advance techology in humanity called "skipping"
        distWalked = 0.0 --used for the walking animation
        veldist = 0 --stands for "velocity distance" only for x and z tho
        altitudeClimbed = 0 -- used for climbing animation tracks
        ComboPunch = 100 --the time since last punch
        ComboSword = 100 --the time since last punch
        ComboPickaxe = 100 --the time since last punch
        ComboUse = 100 --the time since last punch
        ArmMoving = 0
        RightClicked = 0 -- Right Click 
        FallMotion = 0 -- Fall animation
        ThirdPersonCamera = 0 -- Camera mode
        HandMoved = true --Unarmed punch
        lastArmUsed = false --false = right | true = left | purely cosmetic stuff
        lastPos = player.getPos()

    -- Hide vanilla model & armors
        for key, value in pairs(vanilla_model) do
            value.setEnabled(false)    
        end

        for key, value in pairs(armor_model) do
            value.setEnabled(false)    
        end

    -- Apply skin
        model.Body.setTexture("Skin")
        model.MIMIC_RIGHT_ARM_fps.setTexture("Skin")

    -- Check skin type
        if player.getModelType() == "default" then
            model.Body.RightArm.RightArmSlim.setEnabled(false)
            model.Body.LeftArm.LeftArmSlim.setEnabled(false)

            model.Body.RightArm.RightHand.RightHandSlim.setEnabled(false)
            model.Body.LeftArm.LeftHand.LeftHandSlim.setEnabled(false)

            model.MIMIC_RIGHT_ARM_fps.Slim.setEnabled(false)
        else
            model.Body.RightArm.RightArmNormal.setEnabled(false)
            model.Body.LeftArm.LeftArmNormal.setEnabled(false)

            model.Body.RightArm.RightHand.RightHandNormal.setEnabled(false)
            model.Body.LeftArm.LeftHand.LeftHandNormal.setEnabled(false)

            model.MIMIC_RIGHT_ARM_fps.Normal.setEnabled(false)
        end

    -- Define default pose
        pose = {
            head={0,0,0},

            body={0,0,0},

            armLeft={0,0,0},
            armRight={0,0,0},

            legLeft={0,0,0},
            legRight={0,0,0},

            handLeft={0,0,0},
            handRight={0,0,0},

            footleft={0,0,0},
            footRight={0,0,0} 
        }
end

-- Tick function
function tick()
    time = world.getTime()
    ComboPunch = ComboPunch + 1
    ComboSword = ComboSword + 1
    ComboUse = ComboUse + 1
    ComboPickaxe = ComboPickaxe + 1

    local velocity = (player.getPos()-lastPos)*0.52
    localVel = {
        x=(math.sin(math.rad(-player.getRot().y))*velocity.x)+(math.cos(math.rad(-player.getRot().y))*velocity.z),
        0,
        z=(math.sin(math.rad(-player.getRot().y+90))*velocity.x)+(math.cos(math.rad(-player.getRot().y+90))*velocity.z)
    }
    local moveMult = math.max(math.min(veldist*10,1),0)
    veldist = (lenth2({x=velocity.x,y=velocity.z}))
    altitudeClimbed = altitudeClimbed + velocity.y

-- Mainhand & Offhand item data
    Mainhand = player.getEquipmentItem(1).getType()
    Offhand = player.getEquipmentItem(2).getType()

-- Jump leg
    if player.isOnGround() ~= lastgrounded and FallMotion == 1 then--triggers once is grounded or not
        lastgrounded = player.isOnGround()--UPDATE: idk what is this for, but might be useful for the future
        distWalked = distWalked + (PI*0.4)--added skipping
    end

-- Get speed if stainding
    if FallMotion == 0 or player.isUnderwater() and player.isFlying() == false then
        distWalked = distWalked + (veldist*4)
    end

-- Change item swing type
-- Sword
    for I in pairs(ToolSwing) do
        if string.find(player.getEquipmentItem(1).getType(),ToolSwing[I]) then
        else
            SwingType = "Sword"
        end

-- Tools
    for I in pairs(ToolSwing) do
        if string.find(player.getEquipmentItem(1).getType(),ToolSwing[I]) then
            SwingType = "Tool"
        end
    end

-- Punch
    if string.find(Mainhand,"air") then
            SwingType = "Punch"
        end
    end

-- Ping(Left Click)
    if player.isUsingItem() == false and attackKey.isPressed() == true then
    -- パンチ
        if SwingType == "Punch" then
            network.ping("LeftClickPunch")
        end
    -- ツール
        if SwingType == "Tool" then
            network.ping("LeftClickPickaxe")
        end
    -- その他
        if SwingType == "Sword" then
            network.ping("LeftClickSword")
        end
    end

-- Ping(右クリック/捨てる)
    if interactKey.isPressed() or dropKey.isPressed() then
        network.ping("RightClick")
    end

-- 地上空中チェック
    if player.isOnGround() and FallMotion == 1 then
        FallMotion = 0
    end

-- 落下開始
    if velocity.y < -0.17 then
        FallMotion = 1
    end

-- 上昇開始
    if player.isOnGround() then
    else
        if velocity.y > 0.1 then
            FallMotion = 1
        end
    end
    if renderer.isFirstPerson() then
        model.MIMIC_RIGHT_ARM_fps.setEnabled(true)
    else
        model.MIMIC_RIGHT_ARM_fps.setEnabled(false)
end

-- Animate Model
    head.setRot(lerp_3d(model.Body.MIMIC_HEAD_MAIN.offset.getRot(),pose.head,stiffness))

    body.setRot(lerp_3d(model.Body.getRot(),pose.body,stiffness))

    leftarm.setRot(lerp_3d(model.Body.LeftArm.getRot(),pose.armLeft,stiffness))
    lefthand.setRot(lerp_3d(model.Body.LeftArm.LeftHand.getRot(),pose.handLeft,stiffness))

    rightarm.setRot(lerp_3d(model.Body.RightArm.getRot(),pose.armRight,stiffness))
    righthand.setRot(lerp_3d(model.Body.RightArm.RightHand.getRot(),pose.handRight,stiffness))

    leftleg.setRot(lerp_3d(model.Body.LeftLeg.getRot(),pose.legLeft,stiffness))
    rightleg.setRot(lerp_3d(model.Body.RightLeg.getRot(),pose.legRight,stiffness))

    leftfoot.setRot(lerp_3d(model.Body.LeftLeg.LeftFoot.getRot(),pose.footleft,stiffness))
    rightfoot.setRot(lerp_3d(model.Body.RightLeg.RightFoot.getRot(),pose.footRight,stiffness))


--待機モーション
    if veldist < 0.1 then
        pose.head = {0,4,0}
        pose.legLeft = {0,0,-3}
        pose.footleft = {0,0,0}
        pose.legRight = {0,0,3}
        pose.footRight = {0,0,0}
        pose.armLeft = {math.cos(time*0.1)*2-1,0,math.sin(time*0.1)*5-10.0}
        pose.armRight = {-math.cos(time*0.1)*2+1,0,-math.sin(time*0.1)*5+10.0}
        pose.handLeft = {0,0,0}
        pose.handRight = {0,0,0}
    end

    if ArmMoving == 0 then
        pose.body = {0,0,0}
        model.Body.setPos({0,0,0}) 
    end

--ダッシュ
    if veldist > 0.01 then
        if player.isSprinting() then
            pose.head = {20,0,0}
            pose.legLeft = {(math.sin(distWalked)*80+20)*moveMult,0,-1}
            pose.footleft = {(math.sin(distWalked+math.rad(-(90*dotp(localVel.x+0.01))))*(45)-45)*moveMult,0,0}
            pose.legRight = {(math.sin(distWalked)*-80+20)*moveMult,0,1}
            pose.footRight = {(math.sin(distWalked+math.rad(-(90*dotp(localVel.x+0.01))))*-45-45)*moveMult,0,0}
            pose.body = {localVel.x*-50-20,math.sin(distWalked)*5,localVel.z*45}
            model.Body.setPos({0,-math.abs(math.sin(distWalked)),0})
            pose.armLeft = {math.sin(distWalked)*-45*moveMult,0,-15}
            pose.armRight = {math.sin(distWalked)*45*moveMult,0,15}
            pose.handLeft = {(math.sin(distWalked-1)*-10+35)*moveMult,0,0}
            pose.handRight = {(math.sin(distWalked-1)*10+35)*moveMult,0,0}
        else

-- 歩行アニメ
    animation.stopAll()
        pose.head = {0,0,0}
        pose.legLeft = {(math.sin(distWalked)*50+15)*moveMult,0,0}
        pose.footleft = {(math.sin(distWalked+math.rad(-(90*dotp(localVel.x+0.01))))*(45)-45)*moveMult,0,0}
        pose.legRight = {(math.sin(distWalked)*(-50+15))*moveMult,0,0}
        pose.footRight = {(math.sin(distWalked+math.rad(-(90*dotp(localVel.x+0.01))))*-45-45)*moveMult,0,0}
        pose.body = {localVel.x*-50,math.sin(distWalked)*5,localVel.z*70}
        model.Body.setPos({0,-math.abs(math.sin(distWalked))*moveMult,0})
        pose.armLeft = {math.sin(distWalked)*-1*20,0,-10}
        pose.armRight = {math.sin(distWalked)*1*20,0,10}
        pose.handLeft = {(math.sin(distWalked-1)*-10+10)*moveMult,0,0}
        pose.handRight = {(math.sin(distWalked-1)*10+10)*moveMult,0,0}
        end
    end

--空中アニメ
    if FallMotion == 1 then
        pose.body = {localVel.x*-50+math.min(velocity.y*-50,20),0,localVel.z*70}
        pose.head = {0,0,0}
        pose.legLeft = {dotp(math.max(math.sin(distWalked),0))*80,math.max(math.sin(distWalked),0)*15,0}
        pose.legRight = {dotp(math.max(-math.sin(distWalked),0))*80,math.max(-math.sin(distWalked),0)*-15,0}
        pose.footleft = {-dotp(math.max(math.sin(distWalked),0))*80-10,0,0}
        pose.footRight = {-dotp(math.max(-math.sin(distWalked),0))*80-10,0,0}
        pose.armLeft = {0,0,-60}
        pose.armRight = {0,0,60}
        pose.handLeft = {35,0,0}
        pose.handRight = {35,0,0}
    end

-- エリトラ
    if player.getAnimation() == "FALL_FLYING" then
        pose.body = {0,0,0}
        pose.head = {0,0,0}
        pose.legLeft = {0,5,-2}
        pose.legRight = {0,-5,2}
        pose.footleft = {0,0,0}
        pose.footRight = {0,0,0}
        pose.armLeft = {-20,0,-20}
        pose.armRight = {-20,0,20}
        pose.handLeft = {20,0,0}
        pose.handRight = {20,0,0}
        FallMotion = 1
    end

-- 乗ってるときのポーズ
    if player.getVehicle() == nil then
    else
        pose.head = {0,0,0}
        pose.legLeft = {90,25,-3}
        pose.footleft = {-45,0,0}
        pose.legRight = {90,-25,3}
        pose.footRight = {-45,0,0}
        pose.body = {0,0,0}
        model.Body.setPos({0,1,0}) 
        model.Body.LeftArm.setPos({0,0,0})
        pose.armLeft = {20,0,math.sin(time*0.1)*5-3.5}
        pose.armRight = {20,0,-math.sin(time*0.1)*5+3.5}
        pose.handLeft = {25,0,0}
        pose.handRight = {25,0,0}
    end

--スニーク
    if player.isSneaky() then
        pose.legLeft = {(math.sin(distWalked)*60+15)*moveMult,0,0}
        pose.footleft = {(math.sin(distWalked+math.rad(-(90*dotp(localVel.x+0.01))))*(45)-45)*moveMult-0,0,0}
        pose.legRight = {(math.sin(distWalked)*(-60+15))*moveMult+75,0,0}
        pose.footRight = {(math.sin(distWalked+math.rad(-(90*dotp(localVel.x+0.01))))*-45-45)*moveMult-45,0,0}
        pose.body = {localVel.x*-50-30,math.sin(distWalked)*-10,localVel.z*70}
        model.Body.setPos({0,math.abs(math.sin(distWalked)),0})
        pose.armLeft = {math.sin(distWalked)*-45*moveMult+5,0,-25}
        pose.armRight = {math.sin(distWalked)*45*moveMult+5,0,25}
        pose.handLeft = {(math.sin(distWalked-1)*-22.5+25)*moveMult+25,0,0}
        pose.handRight = {(math.sin(distWalked-1)*22.5+25)*moveMult+25,0,0}
        model.Body.setPos({0,3,0})
    end

-- はしごなどを掴んでいるとき
    if player.isClimbing() then
        pose.head = {0,0,0}
        pose.body = {0,0,math.sin(altitudeClimbed*PI*2)*8}
        pose.legLeft = {-math.sin(altitudeClimbed*PI*2)*-60+60,math.cos(altitudeClimbed*PI*2)*22+10,-math.sin(altitudeClimbed*PI*2)*20}
        pose.legRight = {-math.sin(altitudeClimbed*PI*2)*60+60,math.cos(altitudeClimbed*PI*2)*22-10,-math.sin(altitudeClimbed*PI*2)*20}
        pose.footleft = {-math.sin(altitudeClimbed*PI*2)*60-60,0,0}
        pose.footRight = {-math.sin(altitudeClimbed*PI*2)*-60-60,0,0}
        pose.armLeft = {-math.sin(altitudeClimbed*PI*2)*90+90,-math.cos(altitudeClimbed*PI*2)*22+10,0}
        pose.armRight = {-math.sin(altitudeClimbed*PI*2)*-90+90,-math.cos(altitudeClimbed*PI*2)*22-10,0}
        pose.handLeft = {-math.sin(altitudeClimbed*PI*2)*-40+40,0,0}
        pose.handRight = {-math.sin(altitudeClimbed*PI*2)*40+40,0,0}
    end

-- 泳ぎ
    if player.isUnderwater() and player.isFlying() == false then
    if player.isSprinting() then
        pose.head = {0,0,0}
        pose.body = {0,math.sin(distWalked)*10+math.sin(distWalked*2)*2.5,0}
        pose.legLeft = {math.sin(distWalked*1)*45+20,0,0}
        pose.legRight = {-math.sin(distWalked*1)*45+20,0,0}
        pose.footleft = {-math.cos(distWalked*1)*15-25,0,0}
        pose.footRight = {math.cos(distWalked*1)*15-25,0,0}
        pose.armLeft = {math.cos(distWalked*1)*10,0,math.sin(distWalked*1)*10-20}
        pose.armRight = {-math.cos(distWalked*1)*10,0,-math.sin(distWalked*1)*-10+20}
    else

-- 立ち泳ぎ
        pose.head = {0,0,0}
        pose.body = {localVel.x*-300,0,localVel.z*200}
        model.Body.setPos({0,-math.sin(time*0.2+2),0})
        pose.legLeft = {math.cos(time*0.2)*40,0,math.sin(time*0.2)*10-10}
        pose.legRight = {math.cos(time*0.2)*40,0,math.sin(time*0.2)*-10+10}
        pose.footleft = {math.sin(time*-0.2)*45-45,0,0}
        pose.footRight = {math.sin(time*-0.2)*45-45,0,0}
        pose.armLeft = {math.cos(time*0.2)*40,0,math.sin(time*0.2)*10-10}
        pose.armRight = {math.cos(time*0.2)*40,0,math.sin(time*0.2)*-10+10}
        pose.handLeft = {0,0,0}
        pose.handRight = {0,0,0}
    end
end

-- テレポート時にぐるぐるするのを修正
    if (localVel.z) > 0.5 or (localVel.z) < -0.5 then
        pose.body = {0,0,0}
    end

    if (localVel.x) > 0.6 or (localVel.x) < -0.6 then
        pose.body = {0,0,0}
    end

--アイテム手持ち時の待機ポーズ
-- 松明（右手）
    if string.find(Mainhand,"torch") then
        pose.armRight = {-model.Body.MIMIC_HEAD.getRot().x+90-15,-model.Body.MIMIC_HEAD.getRot().y,15}
        pose.handRight = {15,0,0}
    end
-- 松明（左手）
    if string.find(Offhand,"torch") then
        pose.armLeft = {-model.Body.MIMIC_HEAD.getRot().x+90-15,-model.Body.MIMIC_HEAD.getRot().y,-15}
        pose.handLeft = {15,0,0}
    end
-- 剣
    if string.find(player.getEquipmentItem(1).getType(),"sword") then
        pose.armRight[1] = pose.armRight[1]+ 15
        pose.armRight[2] = pose.armRight[2]+ 15
        pose.armRight[3] = pose.armRight[3]+ 5
        pose.handRight[1] = 15
    end
-- ニンジン棒など
    if string.find(player.getEquipmentItem(1).getType(),"on_a_stick") then
        pose.armRight[1] = pose.armRight[1]+ 15
        pose.armRight[2] = pose.armRight[2]+ 15
        pose.armRight[3] = pose.armRight[3]+ 5
        pose.handRight[1] = 15
    end
-- クロスボウ
    if string.find(player.getEquipmentItem(1).getType(),"crossbow") then
        pose.handLeft = {5,0,0}
        pose.handRight = {5,0,0}
    if player.isSneaky() then
        pose.armRight = {-model.Body.MIMIC_HEAD.getRot().x+110,-model.Body.MIMIC_HEAD.getRot().y+15,0}
        pose.armLeft = {-model.Body.MIMIC_HEAD.getRot().x+100,-model.Body.MIMIC_HEAD.getRot().y-45,0}
    else
        pose.armRight = {-model.Body.MIMIC_HEAD.getRot().x+80,-model.Body.MIMIC_HEAD.getRot().y+15,0}
        pose.armLeft = {-model.Body.MIMIC_HEAD.getRot().x+70,-model.Body.MIMIC_HEAD.getRot().y-45,0}
    end
    end

--===========--

-- パンチを進める
    function LeftClickPunch()
        if ComboPunch > 3 then
            ComboPunch = 0
        if HandMoved then
            HandMoved = false
        else
            HandMoved = true
        end
        end
    end

-- 両手パンチ
    if ComboPunch < 20 then--姿勢が元に戻る
        pose.armRight[2] = 45 + pose.armRight[2]
        pose.armLeft[2] = -45 + pose.armLeft[2]
        pose.armRight[1] = 45 + pose.armRight[1]
        pose.armLeft[1] = 45 + pose.armLeft[1]
        pose.handLeft[1] = 80
        pose.handRight[1] = 80
    end

    -- 右手パンチ終了
        if HandMoved == false then
            if ComboPunch < 20 then
                pose.armRight[1] = -model.Body.MIMIC_HEAD.getRot().x+90
                pose.armRight[2] = -45
                pose.handRight[1] = 0
                pose.body[2] = pose.body[2]+ 45
                pose.head[2] = pose.head[2] - 45
            end
        
    -- 右手パンチ構え
        if ComboPunch == 1 then
            pose.armRight[1] = (-model.Body.MIMIC_HEAD.getRot().x+90)*2
            pose.armRight[2] = 180
            pose.armRight[2] = -45
            pose.handRight[1] = 0
            pose.body[2] = pose.body[2]+ 45
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setRot({0,0})
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setPos({0,0,0})
            ComboSword = 200
            ComboUse = 200
            ComboPickaxe = 200
        end
        
    -- 左手パンチ終了
    else
        if ComboPunch < 20 then
            pose.armLeft[1] = -model.Body.MIMIC_HEAD.getRot().x+90
            pose.armLeft[2] = 45
            pose.handLeft[1] = 0
            pose.body[2] = pose.body[2]- 45
            pose.head[2] = pose.head[2] + 45
        end
        
    -- 左手パンチ構え
        if ComboPunch == 1 then
            pose.armLeft[1] = (-model.Body.MIMIC_HEAD.getRot().x+90)*2
            pose.armLeft[2] = 180
            pose.armLeft[2] = 45
            pose.handLeft[1] = 0
            pose.body[2] = pose.body[2]- 45
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setRot({0,0})
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setPos({0,0,0})
            ComboSword = 200
            ComboUse = 200
            ComboPickaxe = 200
        end
    end

--===========--

-- 剣振る
    function LeftClickSword()
        if ComboSword > 3 then
            ComboSword = 0
        if HandMoved then
            HandMoved = false
        else
            HandMoved = true
        end
        end
    end

-- 剣コンボ
    if HandMoved == false then
        if ComboSword < 20 then
            pose.armLeft = {0,0,-25}
            pose.handLeft[1] = 15
            pose.armRight = {110,25,90}
            pose.handRight[1] = 15
            pose.body[2] = pose.body[2]+ 35
            pose.head[2] = pose.head[2]- 35
        end

    if  ComboSword >=1 and ComboSword <=1 then
            pose.armRight = {-25,0,90}
            model.Body.RightArm.setRot({-25,0,90})
            pose.handRight[1] = 15
            pose.handLeft[1] = 0
            pose.body[2] = pose.body[2]- 45
            pose.head[2] = pose.head[2]+ 45
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setRot({-90,180})
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setPos({0,0,1})
            ComboPunch = 200
            ComboUse = 200
            ComboPickaxe = 200
        end

    else
        if ComboSword < 20 then
            pose.armLeft = {0,0,-45}
            pose.handLeft[1] = 15
            pose.armRight = {-25,0,90}
            pose.handRight[1] = 15
            pose.body[2] = pose.body[2]- 25
            pose.head[2] = pose.head[2]+ 15
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setRot({75,0})
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setPos({0,0,-3})
        end
    end
    
--===========--

-- 右クリック動作(メインハンド)
    if HandMoved == false then
        if ComboUse < 20 then--retracting arm
            pose.armRight[1] = 90
            pose.armRight[2] = 45
            pose.armRight[3] = 90
            pose.handRight[1] = 10
            pose.handLeft[1] = 0
            pose.body[2] = pose.body[2]+ 45
            pose.head[2] = pose.head[2]- 45
        end
    
        if  ComboUse == 1 then--投げる直前
            pose.handRight[1] = 0
            pose.armRight = {-25,0,90}
            pose.handLeft[1] = 0
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setRot({0,0})
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setPos({0,0,0})
            ComboPunch = 200
            ComboSword = 200
            ComboPickaxe = 200
        end
    else--left hand punch
        if ComboUse < 20 then--retracting arm
            pose.handRight[1] = 0
            pose.armRight = {-25,0,90}
            pose.handLeft[1] = 0
            pose.body[2] = pose.body[2]- 45
            pose.head[2] = pose.head[2]+ 25
        end

        if  ComboUse == 1 then--投げる直前
            pose.armRight[1] = 90
            pose.armRight[2] = 45
            pose.armRight[3] = 90
            pose.handRight[1] = 10
            pose.handLeft[1] = 0
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setRot({0,0})
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setPos({0,0,0})
            ComboPunch = 200
            ComboSword = 200
            ComboPickaxe = 200
        end
    end

--===========--

-- ツルハシ
    function LeftClickPickaxe()
        if ComboPickaxe > 3 then
            ComboPickaxe = 0
        if HandMoved then
            HandMoved = false
        else
            HandMoved = true
        end
        end
    end

-- 振り下ろし
    if HandMoved == false or HandMoved == true then
        if ComboPickaxe < 20 then
            pose.armLeft = {0,0,-25}
            pose.handLeft[1] = 15
            pose.armRight = {0,-25,0}
            pose.armRight[1] = -model.Body.MIMIC_HEAD.getRot().x+45
            pose.handRight[1] = 15
            pose.body[2] = pose.body[2]+ 25
            pose.head[2] = pose.head[2]- 25
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setRot({55,0})
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setPos({0,-2,-2})
        end

-- 予備動作
    if  ComboPickaxe >=1 and ComboPickaxe <=1 then
            pose.armLeft = {0,0,-25}
            pose.handLeft[1] = 15
            pose.armRight = {0,-25,0}
            pose.armRight[1] = -model.Body.MIMIC_HEAD.getRot().x+215
            pose.handRight[1] = 45
            pose.body[2] = 15
            pose.head[2] = -25
            ComboSword = 200
            ComboPunch = 200
            ComboUse = 200
        end
    end

--===========--

-- 腕のポーズをもとに戻す
    if ComboPunch == 20 or ComboSword == 20 or ComboUse == 20 or ComboPickaxe == 20 then
        HandMoved = true
        model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setRot({0,0})
        model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setPos({0,0,0})
    end
-- 右クリックイベント
function RightClick()

    -- 雑多なアイテム
        if player.isUsingItem() or string.find(Mainhand,"on_a_stick") or string.find(Mainhand,"crossbow") then
            else
                if ComboUse > 3 then
                    ComboUse = 0
                if HandMoved then
                    HandMoved = false
                else
                    HandMoved = true
            end
        end
    end
    -- 弓 (右手)
        if player.getActiveHand() == "MAIN_HAND" and player.getActiveItem() and player.getActiveItem().getUseAction() == "BOW" then
            pose.handRight = {5,0,0}
            pose.handLeft = {5,0,0}
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setRot({0,0})
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setPos({0,0,0})
            pose.body[2] = 0
            pose.head[2] = 0
        if player.isSneaky() then
            pose.armRight = {-model.Body.MIMIC_HEAD.getRot().x+110,-model.Body.MIMIC_HEAD.getRot().y+5,0}
            pose.armLeft = {-model.Body.MIMIC_HEAD.getRot().x+100,-model.Body.MIMIC_HEAD.getRot().y-45,0}
            pose.head[1] = 25
        else
            pose.armRight = {-model.Body.MIMIC_HEAD.getRot().x+80,-model.Body.MIMIC_HEAD.getRot().y+5,0}
            pose.armLeft = {-model.Body.MIMIC_HEAD.getRot().x+70,-model.Body.MIMIC_HEAD.getRot().y-45,0}
        end
        end

    --  弓 (左手)
        if player.getActiveHand() == "OFF_HAND" and player.getActiveItem() and player.getActiveItem().getUseAction() == "BOW" then
            pose.handLeft = {5,0,0}
            pose.handRight = {5,0,0}
            pose.body[2] = 0
            pose.head[2] = 0
        if player.isSneaky() then
            pose.armRight = {-model.Body.MIMIC_HEAD.getRot().x+110,-model.Body.MIMIC_HEAD.getRot().y+45,0}
            pose.armLeft = {-model.Body.MIMIC_HEAD.getRot().x+100,-model.Body.MIMIC_HEAD.getRot().y-5,0}
            pose.head[1] = 25
        else
            pose.armRight = {-model.Body.MIMIC_HEAD.getRot().x+70,-model.Body.MIMIC_HEAD.getRot().y+45,0}
            pose.armLeft = {-model.Body.MIMIC_HEAD.getRot().x+80,-model.Body.MIMIC_HEAD.getRot().y-5,0}
        end
        end

    -- トライデント (右手)
        if player.getActiveHand() == "MAIN_HAND" and player.getActiveItem() and player.getActiveItem().getUseAction() == "SPEAR" then
            pose.armRight = {-model.Body.MIMIC_HEAD.getRot().x+180,-45,-25}
            pose.handRight = {5,0,0}
            pose.body = {0,-45,0}
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setRot({0,0})
            model.Body.RightArm.RightHand.RIGHT_HELD_ITEM.setPos({0,0,0})

        end
    --  トライデント (左手)
        if player.getActiveHand() == "OFF_HAND" and player.getActiveItem() and player.getActiveItem().getUseAction() == "SPEAR" then
            pose.armLeft = {-model.Body.MIMIC_HEAD.getRot().x+180,45,25}
            pose.handLeft = {5,0,0}
            pose.body = {0,45,0}
            pose.head[2] = 0
        end

    -- 盾(右手)
        if player.getActiveHand() == "MAIN_HAND" and player.getActiveItem() and player.getActiveItem().getUseAction() == "BLOCK" then
            pose.armRight = {15,0,0}
            pose.armRight[1] = pose.armRight[1]+ 15
            pose.armRight[2] = pose.armRight[2]+ 45
            pose.handRight = {0,0,0}
            pose.handRight[1] = pose.handRight[1]+ 15
        end
    -- 盾(左手)
        if player.getActiveHand() == "OFF_HAND" and player.getActiveItem() and player.getActiveItem().getUseAction() == "BLOCK" then
            pose.armLeft = {45,0,0}
            pose.armLeft[1] = pose.armLeft[1]- 15
            pose.armLeft[2] = pose.armLeft[2]- 45
            pose.handLeft = {0,0,0}
            pose.handLeft[1] = pose.handLeft[1]+ 15
        end

    -- 望遠鏡 (右手)
        if player.getActiveHand() == "MAIN_HAND" and player.getActiveItem() and player.getActiveItem().getUseAction() == "SPYGLASS" then
            pose.armRight = {-model.Body.MIMIC_HEAD.getRot().x+100,-model.Body.MIMIC_HEAD.getRot().y+15,0}
            pose.handRight = {25,0,0}
            pose.body[2] = 0
            pose.head[2] = 0
        end
    -- 望遠鏡(左手)
        if player.getActiveHand() == "OFF_HAND" and player.getActiveItem() and player.getActiveItem().getUseAction() == "SPYGLASS" then
            pose.armLeft = {-model.Body.MIMIC_HEAD.getRot().x+100,-model.Body.MIMIC_HEAD.getRot().y-15,0}
            pose.handLeft = {25,0,0}
            pose.body[2] = 0
            pose.head[2] = 0
        end

    -- ごはん(右手)
        if player.getActiveHand() == "MAIN_HAND" and player.getActiveItem() and player.getActiveItem().getUseAction() == "EAT" or player.getActiveHand() == "MAIN_HAND" and player.getActiveItem() and player.getActiveItem().getUseAction() == "DRINK" then
            pose.armRight = {-math.cos(time*1.5)*10+75,25,25}
            pose.handRight = {25,0,0}
            pose.body[2] = 0
            pose.head[2] = 0
        end
    -- ごはん（左手）
        if player.getActiveHand() == "OFF_HAND" and player.getActiveItem() and player.getActiveItem().getUseAction() == "EAT" or player.getActiveHand() == "OFF_HAND" and player.getActiveItem() and player.getActiveItem().getUseAction() == "DRINK" then
            pose.armLeft = {-math.cos(time*1.5)*10+75,-25,-25}
            pose.handLeft = {25,0,0}
            pose.body[2] = 0
            pose.head[2] = 0
        end
    end

-- LastPos
        lastPos = player.getPos()
end

-- TPS Camera 
    action_wheel.SLOT_1.setTitle("Toggle Third Person Camera")
    action_wheel.SLOT_1.setItem("minecraft:ender_pearl")
    action_wheel.SLOT_1.setFunction
    (
        function ()
            if ThirdPersonCamera == 0 then
                camera.THIRD_PERSON.setPos({1, -0.2, -2.1})
                camera.THIRD_PERSON.setRot({15, 0, 0})
                ThirdPersonCamera = 1
            else
                camera.THIRD_PERSON.setPos({0, 0, 0})
                camera.THIRD_PERSON.setRot({0, 0, 0})
                ThirdPersonCamera = 0
            end
        end
    )