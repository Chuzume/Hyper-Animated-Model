--========================================================--
--GNs animated player by GNamimates
--version 1.1
--adds cool animations using the one and only figura mod!
--========================================================--

-- アニメに必要なもの定義
    PI = 3.14159

    LastPos2 = vectors.of({0,0,0})
    Pos2 = vectors.of({0,0,0})

    function tick()
        LastPos2 = Pos2
        Pos2 = vectors.of({math.sin(world.getTime()*0.2)*20,0,0})
    end


-- キー登録
    attackKey = keybind.getRegisteredKeybind("key.attack")
    interactKey = keybind.getRegisteredKeybind("key.use")
    dropKey = keybind.getRegisteredKeybind("key.drop")

-- Ping登録
    network.registerPing("LeftClickPunch")
    network.registerPing("LeftClickSword")
    network.registerPing("LeftClickUse")
    network.registerPing("LeftClickPickaxe")
    network.registerPing("RightClick")
    network.registerPing("Drop")

--======CONFIG=======--
-- I don suggest changing this one, because it can break the punching animation
stiffness = 0.1 --the lower the value is, the smoother the blending between animation tracks is
-- if the player is using a slim skin
isSlim = true
--note: dosent have to be the full name of the item, just a key word of it

-- ツルハシタイプの振り方をするアイテム
    ToolSwing = {"shovel","hoe","pickaxe","shield"}

-- 振らないアイテム
    NoSwing = {"air"}

-- Init処理
function player_init()
    lastgrounded = false--used to simulate AI advance techology in humanity called "skipping"
    distWalked = 0.0 --used for the walking animation
    veldist = 0 --stands for "velocity distance" only for x and z tho
    altitudeClimbed = 0 -- used for climbing animation tracks
    ComboPunch = 100 --the time since last punch
    ComboSword = 100 --the time since last punch
    ComboPickaxe = 100 --the time since last punch
    ComboUse = 100 --the time since last punch
    ArmMoving = 0
    GhostMode = 0 -- スペクテイターかどうか
    FallMotion = 0 -- 落下アニメ
    ThirdPersonCamera = 0 -- カメラモード
    HandMoved = true --素手パンチのコンボ
    lastArmUsed = false --false = right | true = left | purely cosmetic stuff
    lastPos = player.getPos()

-- バニラモデル非表示
    for key, value in pairs(vanilla_model) do
        value.setEnabled(false)    
    end

    for key, value in pairs(armor_model) do
        value.setEnabled(false)    
    end

-- アニメ補間に必要？
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

--===== ANIMATIONS N STUFF=====--
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

-- 
--    log(client.getFPS())
--    local _, _, fpsStr = find(getFPS(), "(%d+) fps")
--    local fps = tonumber(fpsStr)

-- データ取得
    Mainhand = player.getEquipmentItem(1).getType()
    Offhand = player.getEquipmentItem(2).getType()

-- ジャンプの足
    if player.isOnGround() ~= lastgrounded and FallMotion == 1 then--triggers once is grounded or not
        lastgrounded = player.isOnGround()--UPDATE: idk what is this for, but might be useful for the future
        distWalked = distWalked + (PI*0.4)--added skipping
    end

-- 地上にいるならベクトルを取得
    if FallMotion == 0 or player.isUnderwater() and player.isFlying() == false then
        distWalked = distWalked + (veldist*4)
    end

-- 腕を回す動作を検知
function isAttacking2()
    return
        (vanilla_model.RIGHT_ARM.getOriginRot().z < 0)
    end

-- アイテムの振り方を定義
    for I in pairs(ToolSwing) do
        if string.find(player.getEquipmentItem(1).getType(),ToolSwing[I]) then
        else
            SwingType = "Sword"
        end

-- ツール
    for I in pairs(ToolSwing) do
        if string.find(player.getEquipmentItem(1).getType(),ToolSwing[I]) then
            SwingType = "Tool"
        end
    end

-- パンチ
    if string.find(Mainhand,"air") then
            SwingType = "Punch"
        end
    end

-- Ping(左クリック)
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

--待機モーション
    if veldist < 0.1 then
        pose.head = {0,0,0}
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
            pose.body = {localVel.x*-50-20,math.sin(distWalked)*5,localVel.z*70}
            model.Body.setPos({0,-math.abs(math.sin(distWalked)),0})
            pose.armLeft = {math.sin(distWalked)*-15*moveMult-45,0,-35}
            pose.armRight = {math.sin(distWalked)*15*moveMult-45,0,35}
            pose.handLeft = {(math.sin(distWalked-1)*-10+10)*moveMult,0,0}
            pose.handRight = {(math.sin(distWalked-1)*10+10)*moveMult,0,0}
        else

-- 歩行アニメ
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

--スニーク
    if player.isSneaky() then
        pose.head = {30,0,0}
        pose.legLeft = {(math.sin(distWalked)*120+15)*moveMult+30,0,0}
        pose.footleft = {(math.sin(distWalked+math.rad(-(90*dotp(localVel.x+0.01))))*(45)-45)*moveMult,0,0}
        pose.legRight = {(math.sin(distWalked)*(-120+15))*moveMult+30,0,0}
        pose.footRight = {(math.sin(distWalked+math.rad(-(90*dotp(localVel.x+0.01))))*-45-45)*moveMult,0,0}
        pose.body = {localVel.x*-50-30,math.sin(distWalked)*-10,localVel.z*70}
        model.Body.setPos({0,math.abs(math.sin(distWalked)),0})
        pose.armLeft = {math.sin(distWalked)*-45*moveMult+25,0,0}
        pose.armRight = {math.sin(distWalked)*45*moveMult+25,0,0}
        pose.handLeft = {(math.sin(distWalked-1)*-22.5+25)*moveMult,0,0}
        pose.handRight = {(math.sin(distWalked-1)*22.5+25)*moveMult,0,0}
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
        --pose.handLeft = {0,0,math.sin(distWalked*1)*40-40}
        --pose.handRight = {0,0,math.sin(distWalked*-1)*-40+40}
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

-- 右クリック動作(オフハンド)
--    if HandMovedThrow == false then
--        if ComboUse < 20 then--retracting arm
--            pose.armLeft[1] = 90
--            pose.armLeft[2] = -45
--            pose.armLeft[3] = -90
--            pose.handLeft[1] = 10
--            pose.body[2] = pose.body[2]- 45
--            pose.head[2] = pose.head[2]+ 45
--        end
--
--        if  ComboUse == 1 then--投げる直前
--            pose.handLeft[1] = 0
--            pose.armLeft = {-25,0,-90}
--            pose.handLeft[1] = 0
--        end
--    else--left hand punch
--        if ComboUse < 20 then--retracting arm
--            pose.handLeft[1] = 0
--            pose.armLeft = {-25,0,-90}
--            pose.handLeft[1] = 0
--            pose.body[2] = pose.body[2]+ 45
--            pose.head[2] = pose.head[2]- 25
--        end
--
--        if  ComboUse == 1 then--投げる直前
--            pose.armLeft[1] = 90
--            pose.armLeft[2] = -45
--            pose.armLeft[3] = -90
--            pose.handLeft[1] = 10
--        end
--    end

-- もとに戻る
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
    
-- オバケモード
    if player.getGamemode() == "SPECTATOR" and GhostMode == 0 then
        model.Body.MIMIC_HEAD.offset.setEnabled(false)
        model.Body.MIMIC_HEAD.Ghost.setEnabled(true)
        GhostMode = 1
    end

-- オバケモード解除
    if player.getGamemode() == "SPECTATOR" then 
        else if GhostMode == 1 then
            model.Body.MIMIC_HEAD.offset.setEnabled(true)
            model.Body.MIMIC_HEAD.Ghost.setEnabled(false)
            GhostMode = 0
        end
    end

-- なにかはわからないけど重要らしい
        lastPos = player.getPos()
    end

-- ポーズファンクション
    function render(delta)
        -- mode model.MIMIC_RIGHT_ARM_fps.setEnabled(renderer.isFirstPerson()) dosent work for some reason...
        if renderer.isFirstPerson() then
            model.MIMIC_RIGHT_ARM_fps.setEnabled(true)
        else
            model.MIMIC_RIGHT_ARM_fps.setEnabled(false)
        end

--モデルのポーズ補間
    model.Body.MIMIC_HEAD.offset.setRot(tableLerp(model.Body.MIMIC_HEAD.offset.getRot(),pose.head,stiffness))
        
    model.Body.setRot(tableLerp(model.Body.getRot(),pose.body,stiffness))
        
    model.Body.LeftArm.setRot(tableLerp(model.Body.LeftArm.getRot(),pose.armLeft,stiffness))
    model.Body.RightArm.setRot(tableLerp(model.Body.RightArm.getRot(),pose.armRight,stiffness))

    model.Body.LeftLeg.setRot(tableLerp(model.Body.LeftLeg.getRot(),pose.legLeft,stiffness))
    model.Body.RightLeg.setRot(tableLerp(model.Body.RightLeg.getRot(),pose.legRight,stiffness))
        
    model.Body.LeftLeg.LeftFoot.setRot(tableLerp(model.Body.LeftLeg.LeftFoot.getRot(),pose.footleft,stiffness))
    model.Body.RightLeg.RightFoot.setRot(tableLerp(model.Body.RightLeg.RightFoot.getRot(),pose.footRight,stiffness))
        
    model.Body.LeftArm.LeftHand.setRot(tableLerp(model.Body.LeftArm.LeftHand.getRot(),pose.handLeft,stiffness))
    model.Body.RightArm.RightHand.setRot(tableLerp(model.Body.RightArm.RightHand.getRot(),pose.handRight,stiffness))

end

--the "im too dumb to find them so I made my own" section
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

--things I borrowed
    function lerp(a, b, x)
        return a + (b - a) * x
    end

    function tableLerp(a, b, x)
        return {lerp(a[1],b[1],x),lerp(a[2],b[2],x),lerp(a[3],b[3],x)}
    end

-- テクスチャの大きさ
    texture_height = 128
    texture_width = 256

-- カスタム鎧(by dragekk)
armor = {
    head = { model.Body.MIMIC_HEAD.offset.Helmet },
    chest = { model.Body.Chestplate, model.Body.RightArm.Chestplate, model.Body.LeftArm.Chestplate, model.Body.RightArm.RightHand.Chestplate, model.Body.LeftArm.LeftHand.Chestplate, model.MIMIC_RIGHT_ARM_fps.cubeChestplate },
    elytra = { model.Body.RIGHT_ELYTRA, model.Body.LEFT_ELYTRA },
    legs = { model.Body.Leggings, model.Body.LeftLeg.Leggings, model.Body.RightLeg.Leggings ,model.Body.LeftLeg.LeftFoot.Leggings, model.Body.RightLeg.RightFoot.Leggings},
    boots = { model.Body.LeftLeg.LeftFoot.Boots, model.Body.RightLeg.RightFoot.Boots}
    }

--custom armor function
    function update_armor(armor_table, x, table_vector)
        for key, value in pairs(armor_table) do
            value[x](table_vector)
        end
    end
    
    function tick()
        custom_armor()
    end
    
    function custom_armor()
        local boots = player.getEquipmentItem(3).getType()
        local legs = player.getEquipmentItem(4).getType()
        local chest = player.getEquipmentItem(5).getType()
        local head = player.getEquipmentItem(6).getType()

    --If no helmet
    update_armor(armor.head, "setColor", {1, 1, 1})
    if head == "minecraft:air" then
        update_armor(armor.head, "setEnabled", false)
    else
        update_armor(armor.head, "setEnabled", true)

    end

    --Check enchant
        if player.getEquipmentItem(6).hasGlint() then
            update_armor(armor.head, "setShader", "Glint")
        else
            update_armor(armor.head, "setShader", "None")
        end
    
    --Check current armor
    if head == "minecraft:turtle_helmet" then
        update_armor(armor.head, "setUV", {128/texture_width, 96/texture_height})
    elseif head == "minecraft:netherite_helmet" then
        update_armor(armor.head, "setUV", {128/texture_width, 48/texture_height})
    elseif head == "minecraft:diamond_helmet" then
        update_armor(armor.head, "setUV", {128/texture_width, 0})
    elseif head == "minecraft:iron_helmet" then
        update_armor(armor.head, "setUV", {0, 0})
    elseif head == "minecraft:golden_helmet" then
        update_armor(armor.head, "setUV", {0, 48/texture_height})
    elseif head == "minecraft:chainmail_helmet" then
        update_armor(armor.head, "setUV", {64/texture_width, 0})
    elseif head == "minecraft:leather_helmet" then
        update_armor(armor.head, "setUV", {64/texture_width, 48/texture_height})
        if player.getEquipmentItem(6).getTag() ~= nil and player.getEquipmentItem(6).getTag().display ~= nil and player.getEquipmentItem(6).getTag().display.color ~= nil then
            update_armor(armor.head, "setColor", vectors.intToRGB(player.getEquipmentItem(6).getTag().display.color))
        else
            update_armor(armor.head, "setColor", {134/255 , 82/255 , 53/255})
        end
    end
    
    --chest
        update_armor(armor.chest, "setColor", {1, 1, 1})
        if chest == "minecraft:air" or chest == "minecraft:elytra" then
            update_armor(armor.chest, "setEnabled", false)
        else
            update_armor(armor.chest, "setEnabled", true)
        end
    
        if player.getEquipmentItem(5).hasGlint() then
            update_armor(armor.chest, "setShader", "Glint")
            update_armor(armor.elytra, "setShader", "Glint")
        else
            update_armor(armor.chest, "setShader", "None")
            update_armor(armor.elytra, "setShader", "None")
        end
    
        if chest == "minecraft:netherite_chestplate" then
            update_armor(armor.chest, "setUV", {128/texture_width, 48/texture_height})
        elseif chest == "minecraft:diamond_chestplate" then
            update_armor(armor.chest, "setUV", {128/texture_width, 0})
        elseif chest == "minecraft:iron_chestplate" then
            update_armor(armor.chest, "setUV", {0, 0})
        elseif chest == "minecraft:golden_chestplate" then
            update_armor(armor.chest, "setUV", {0, 48/texture_height})
        elseif chest == "minecraft:chainmail_chestplate" then
            update_armor(armor.chest, "setUV", {64/texture_width, 0})
        elseif chest == "minecraft:leather_chestplate" then
            update_armor(armor.chest, "setUV", {64/texture_width, 48/texture_height})
            if player.getEquipmentItem(5).getTag() ~= nil and player.getEquipmentItem(5).getTag().display ~= nil and player.getEquipmentItem(5).getTag().display.color ~= nil then
                update_armor(armor.chest, "setColor", vectors.intToRGB(player.getEquipmentItem(5).getTag().display.color))
            else
                update_armor(armor.chest, "setColor", {134/255 , 82/255 , 53/255})
            end
        end
    
        --legs
        update_armor(armor.legs, "setColor", {1, 1, 1})
        if legs == "minecraft:air" or legs == "minecraft:elytra" then
            update_armor(armor.legs, "setEnabled", false)
        else
            update_armor(armor.legs, "setEnabled", true)
        end
    
        if player.getEquipmentItem(4).hasGlint() then
            update_armor(armor.legs, "setShader", "Glint")
        else
            update_armor(armor.legs, "setShader", "None")
        end
    
        if legs == "minecraft:netherite_leggings" then
            update_armor(armor.legs, "setUV", {128/texture_width, 48/texture_height})
        elseif legs == "minecraft:diamond_leggings" then
            update_armor(armor.legs, "setUV", {128/texture_width, 0})
        elseif legs == "minecraft:iron_leggings" then
            update_armor(armor.legs, "setUV", {0, 0})
        elseif legs == "minecraft:golden_leggings" then
            update_armor(armor.legs, "setUV", {0, 48/texture_height})
        elseif legs == "minecraft:chainmail_leggings" then
            update_armor(armor.legs, "setUV", {64/texture_width, 0})
        elseif legs == "minecraft:leather_leggings" then
            update_armor(armor.legs, "setUV", {64/texture_width, 48/texture_height})
            if player.getEquipmentItem(4).getTag() ~= nil and player.getEquipmentItem(4).getTag().display ~= nil and player.getEquipmentItem(4).getTag().display.color ~= nil then
                update_armor(armor.legs, "setColor", vectors.intToRGB(player.getEquipmentItem(4).getTag().display.color))
            else
                update_armor(armor.legs, "setColor", {134/255 , 82/255 , 53/255})
            end
        end
    
        --boots
        update_armor(armor.boots, "setColor", {1, 1, 1})
        if boots == "minecraft:air" or boots == "minecraft:elytra" then
            update_armor(armor.boots, "setEnabled", false)
        else
            update_armor(armor.boots, "setEnabled", true)
        end
    
        if player.getEquipmentItem(3).hasGlint() then
            update_armor(armor.boots, "setShader", "Glint")
        else
            update_armor(armor.boots, "setShader", "None")
        end
    
        if boots == "minecraft:netherite_boots" then
            update_armor(armor.boots, "setUV", {128/texture_width, 48/texture_height})
        elseif boots == "minecraft:diamond_boots" then
            update_armor(armor.boots, "setUV", {128/texture_width, 0})
        elseif boots == "minecraft:iron_boots" then
            update_armor(armor.boots, "setUV", {0, 0})
        elseif boots == "minecraft:golden_boots" then
            update_armor(armor.boots, "setUV", {0, 48/texture_height})
        elseif boots == "minecraft:chainmail_boots" then
            update_armor(armor.boots, "setUV", {64/texture_width, 0})
        elseif boots == "minecraft:leather_boots" then
            update_armor(armor.boots, "setUV", {64/texture_width, 48/texture_height})
            if player.getEquipmentItem(3).getTag() ~= nil and player.getEquipmentItem(3).getTag().display ~= nil and player.getEquipmentItem(3).getTag().display.color ~= nil then
                update_armor(armor.boots, "setColor", vectors.intToRGB(player.getEquipmentItem(3).getTag().display.color))
            else
                update_armor(armor.boots, "setColor", {134/255 , 82/255 , 53/255})
            end
        end
    end

-- 自分の姿を眺めながら遊べるカメラがほしい！
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