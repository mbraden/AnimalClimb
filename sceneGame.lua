local composer = require( "composer" )
local scene = composer.newScene()
local widget = require("widget")
local buttonLeft, buttonRight, buttonFire, buttonPause, divLine
local currentImage = 1
local timerMain
local sheetFlyingBird
local sheetFlyingBird2
local sheetGuyWalk
local seqflyingbird
local seqflyingbird2
local seqguywalk
local spriteFlyingBird
local spriteFlyingBird2
local spriteGuyWalk
local tableAnimals = {}
local tableStack1 = {}
local sceneGroupGlobal
local divLineSpace = 73
local bPaused = false
local labelScore
local score = 0

local bg01


local function checkMemory()
   collectgarbage( "collect" )
   local memUsage_str = string.format( "MEMORY = %.3f KB", collectgarbage( "count" ) )
   print( memUsage_str, "TEXTURE = "..(system.getInfo("textureMemoryUsed") / (1024 * 1024) ) )
end



--timer.performWithDelay( 1000, checkMemory, 0 )



-----------------------------------------
-------    PAUSE BUTTON PRESSED
-----------------------------------------
local function handleButtonPauseEvent( event)
    if (event.phase == "ended") then
        if (bPaused == false) then
            x = timer.pause(timerMain)
            bPaused = true
        else
            x = timer.resume(timerMain)
            bPaused = false
        end
        
    end
end



-----------------------------------------
-------    LEFT BUTTON PRESSED
-----------------------------------------
local function handleButtonLeftEvent( event)
    if (event.phase == "ended") then        
        tableAnimals[currentImage].isVisible = false
        currentImage = currentImage - 1
        if (currentImage < 1) then
            currentImage = table.maxn(tableAnimals)
        end
        tableAnimals[currentImage].isVisible = true
    end
end

-----------------------------------------
-------    RIGHT BUTTON PRESSED
-----------------------------------------
local function handleButtonRightEvent( event)
    if (event.phase == "ended") then        
        tableAnimals[currentImage].isVisible = false
        currentImage = currentImage + 1
        if (currentImage > table.maxn(tableAnimals)) then
            currentImage = 1
        end
        tableAnimals[currentImage].isVisible = true
    end
end


-----------------------------------------
-------    UPDATE SCORE
-----------------------------------------
function updateScore()
    labelScore.text = score
end


-----------------------------------------
-------    FIRE BUTTON PRESSED
-----------------------------------------
local function handleButtonFireEvent( event)
    local animalRemoved = false

    if (event.phase == "ended") then
        --print("Killing")
        --LOOP THROUGH THE STACK REMOVING ALL THE ONES THAT MATCH WHAT WAS CLICKED       
        local count
        for count = table.maxn(tableStack1) , 1, -1 do            --THIS GOES IN REVERSE SO THAT AS THEY ARE REMOVED, THERE ARE ALWAYS MORE BELOW
            if (tableStack1[count].sprite.sequence == tableAnimals[currentImage].sequence) then
                score = score + tableStack1[count].value
                tableStack1[count].sprite:removeSelf() --THIS REMOVES THE SPRITE VISUALLY
                table.remove(tableStack1, count)  --THIS REMOVES THE ELEMENT FROM THE TABLE

                animalRemoved = true
           
            end            
        end

        if (animalRemoved == true)     then
            --UPDATE SCORE ON SCREEN
            updateScore()

            --NOW DROP ALL LEFT DOWN
            dropRemainingAnimals()
        
        end


    end
end



-----------------------------------------
-------    DROP REMAINING ANIMALS
-----------------------------------------
function dropRemainingAnimals()
    
    timer.pause(timerMain)

    if (table.maxn(tableStack1) > 0) then

        --LOOP THROUHG LIST FROM BOTTOM(1) TO TOP COLLAPSING THE ANIMALS
        local count, newSpriteY
        
        for count=1, table.maxn(tableStack1), 1 do
            
            newSpriteY = getSpriteDestinationY(count,  tableStack1)                        
            tableStack1[count].destinationY = newSpriteY
            transition.to(tableStack1[count].sprite, { time=500, y=newSpriteY, transition=easing.linear } )
                        
        end

    end
    timer.resume(timerMain)
    
end




-------------------------------------------------------------------
--       GETSPRITEDESTINATIONY
-------------------------------------------------------------------
function getSpriteDestinationY(indexUpper, stack)
    local indexLower, halfHeightLower, halfHeightUpper, destY

    if (indexUpper == 1) then
        destY = divLine.y - divLineSpace 
    else
        indexLower = indexUpper - 1
        halfHeightLower = math.round((stack[indexLower].sprite.height * stack[indexLower].sprite.yScale) * .5)
        halfHeightUpper = math.round((stack[indexUpper].sprite.height * stack[indexUpper].sprite.yScale) * .5)    
        destY = stack[indexLower].destinationY - halfHeightLower - halfHeightUpper
    end
    
    return destY
end




-------------------------------------------------------
--       GAME LISTENERS FUNCTION TO START ALL TIMERS, ETC...
--------------------------------------------------------
function gameListeners(cmd)
    if (cmd == "start") then
        timerMain = timer.performWithDelay(2000, addAnimalToStack, 0 )
    else


    	--REMOVE OBJECTS
    	labelScore:removeSelf()
    	buttonLeft:removeSelf()
    	buttonRight:removeSelf()
    	buttonFire:removeSelf()
    	--buttonPause:removeSelf()
    	divLine:removeSelf()
    	bg01:removeSelf()



    	--KILL TIMER
        timer.cancel(timerMain)
        timerMain = nil


        --REMOVE EVERTYHING FROM TABLESTACK1        
        for i = table.maxn(tableStack1) , 1, -1 do            --THIS GOES IN REVERSE SO THAT AS THEY ARE REMOVED, THERE ARE ALWAYS MORE BELOW
        	print("I="..i)
        	tableStack1[i].sprite:removeSelf() --THIS REMOVES THE SPRITE VISUALLY            
        	table.remove(tableStack1, i)                                
        end
        tableStack1 = {}

        --REMOVE EVERTYHING FROM TABLEANIMALS
        for i=1, table.maxn(tableAnimals), 1 do            
        	table.remove(tableAnimals, i)                                
        end        
		tableAnimals = {}
		

    end
end






------------------------------------------------------
--          ADD NEW RANDOM ANIMAL TO STACK
-------------------------------------------------------
function addAnimalToStack()
    local newSpriteDestinationY

    --get the random number(animal)
    local x = math.random(table.maxn(tableAnimals))
    

    --CREATE TEMP COPY OF RANDOMLY SELECTED SPRITE    
    local spriteTemp 
    local seq = tableAnimals[x].sequence
    if (seq == "seqflyingbird") then
        spriteTemp = display.newSprite(sheetFlyingBird, seqflyingbird)
    elseif (seq == "seqflyingbird2") then
        spriteTemp = display.newSprite(sheetFlyingBird2, seqflyingbird2)
    elseif (seq == "seqguywalk") then
        spriteTemp = display.newSprite(sheetGuyWalk, seqguywalk)
    end
    spriteTemp:scale(tableAnimals[x].xScale, tableAnimals[x].yScale)    
    spriteTemp.x = display.contentWidth * .5
    spriteTemp.y = 0
    sceneGroupGlobal:insert(spriteTemp)
    spriteTemp:play()

    
    --BUILD SPRITE NODE & INSERT IT INTO THE STACK TABLE
    local tableNode = {}
    tableNode["sprite"] = spriteTemp
    tableNode["value"] = 100
    table.insert(tableStack1, tableNode)
    newSpriteDestinationY = getSpriteDestinationY( table.maxn(tableStack1), tableStack1 )
    tableStack1[table.maxn(tableStack1)].destinationY = newSpriteDestinationY
    

    
    --NOW DROP THE SPRITE DOWN ONTO THE STACK USING DESTINATIONY PROPERTY AS TRANSITION TO VALUE    
    local dif = math.abs((tableStack1[table.maxn(tableStack1)].destinationY) - (tableStack1[table.maxn(tableStack1)].sprite.y))
    local dropTime    
    
    if (dif < 200 ) then
        dropTime = 275
    elseif (dif >=200) and (dif < 500) then
        dropTime = 350
    elseif (dif >= 500) then
        dropTime = 500
    end

    transition.to(tableStack1[table.maxn(tableStack1)].sprite, { time=dropTime, y=tableStack1[table.maxn(tableStack1)].destinationY , transition=easing.linear } )


    --STACK HAS REACHED THE TOP WHEN DESTINATION IS < 0 (ABOVE TOP OF SCREEN)
    if (tableStack1[table.maxn(tableStack1)].destinationY < 0) then
        endGame()
    end



end








------------------------------------------------------------
--         END GAME
------------------------------------------------------------
function endGame()
    gameListeners("end")    
    composer.gotoScene( "sceneGameOver", "slideRight", 800  )
end








--------------------------------------
--         SCENE CREATE
--------------------------------------
function scene:create( event )

	print("SCENE:CREATE")
    sceneGroupGlobal = self.view
    
end




--------------------------------------
--         LOAD SPRITE STUFF
--------------------------------------
function loadSprites(sceneGroup)
	print("LOADING SPRITES")




	--SCORE LABEL
    labelScore = display.newText("0000",70,300, native.systemFont, 46)
	sceneGroup:insert(labelScore)
    


	--SET RANDOM SEED
    math.randomseed(os.time())

    


    --BACKGROUND 01
    --bg01 = display.newImage( "assets/bg01.png" )
    bg01 = display.newImageRect( "assets/background.png", 320, 570 )
    --bg01.x = display.contentWidth
    --bg01.y = display.contentHeight
    bg01.x = display.contentCenterX
    bg01.y = display.contentCenterY
    --bg01:scale(.5, .5)
    sceneGroup:insert(bg01)




    --LEFT BUTTON
    buttonLeft = widget.newButton {         
        id = "buttonleft", 
        x = display.contentWidth * .20,
        y = display.contentHeight - 175,        
        defaultFile = "assets/btnleft.png",
        overFile = "assets/btnleft_pressed.png",
        onEvent = handleButtonLeftEvent
    }
    sceneGroup:insert(buttonLeft)

    --RIGHT BUTTON
    buttonRight = widget.newButton {         
        id = "buttonright", 
        x = display.contentWidth * .80,
        y = display.contentHeight - 175,        
        defaultFile = "assets/btnright.png",
        overFile = "assets/btnright_pressed.png",
        onEvent = handleButtonRightEvent
    }
    sceneGroup:insert(buttonRight)


    --FIRE BUTTON
    buttonFire = widget.newButton {         
        id = "buttonfire", 
        x = display.contentWidth * .50,
        y = display.contentHeight - 175,        
        defaultFile = "assets/btnfire.png",
        overFile = "assets/btnfire.png",
        onEvent = handleButtonFireEvent
    }
    sceneGroup:insert(buttonFire)



    --PAUSE BUTTON
	



    --IMAGE SHEET OF FLYING BIRD 1
    local optionsFlyingBird = 
    {
        width = 125,
        height = 125,
        numFrames = 16
    }
    sheetFlyingBird = graphics.newImageSheet("assets/ss1.png", optionsFlyingBird)


    --IMAGE SHEET OF FLYING BIRD 2
    local optionsFlyingBird2 = 
    {
        width = 125,
        height = 125,
        numFrames = 16
    }
    sheetFlyingBird2 = graphics.newImageSheet("assets/ss2.png", optionsFlyingBird2)
    
    --IMAGE SHEET OF GUYWALK
    local optionsGuyWalk = 
    {
        width = 125,
        height = 125,
        numFrames = 16
    }
    sheetGuyWalk = graphics.newImageSheet("assets/ss3.png", optionsGuyWalk)






    --SEQUENCE FOR FLYING BIRD
    seqflyingbird = 
    {
        {
            name = "seqflyingbird",
            start = 1,
            count = 16,
            time = 650,
            loopCount = 0,
            loopDirection = "forward"
        }
    }


    --SEQUENCE FOR FLYING BIRD 2
    seqflyingbird2 = 
    {
        {
            name = "seqflyingbird2",
            start = 1,
            count = 16,
            time = 650,
            loopCount = 0,
            loopDirection = "forward"
        }
    }

    --SEQUENCE FOR GUY WALK
    seqguywalk = 
    {
        {
            name = "seqguywalk",
            start = 1,
            count = 16,
            time = 650,
            loopCount = 0,
            loopDirection = "forward"
        }
    }




    --SPRITE FOR FLYING BIRD
    spriteFlyingBird = display.newSprite(sheetFlyingBird, seqflyingbird)
    spriteFlyingBird:scale(.5, .5)
    sceneGroup:insert(spriteFlyingBird)
    spriteFlyingBird.x = display.contentWidth * .5
    spriteFlyingBird.y = buttonFire.y - 190
    tableAnimals[1] = spriteFlyingBird
    tableAnimals[1].isVisible = true
    spriteFlyingBird:play()

    --SPRITE FOR FLYING BIRD 2
    spriteFlyingBird2 = display.newSprite(sheetFlyingBird2, seqflyingbird2)    
    spriteFlyingBird2:scale(.5, .5)
    sceneGroup:insert(spriteFlyingBird2)
    spriteFlyingBird2.x = display.contentWidth * .5
    spriteFlyingBird2.y = buttonFire.y - 190
    tableAnimals[2] = spriteFlyingBird2
    tableAnimals[2].isVisible = false
    spriteFlyingBird2:play()

    --SPRITE FOR GUY WALK
    spriteGuyWalk = display.newSprite(sheetGuyWalk, seqguywalk)    
    spriteGuyWalk:scale(.5, .5)
    sceneGroup:insert(spriteGuyWalk)
    spriteGuyWalk.x = display.contentWidth * .5
    spriteGuyWalk.y = buttonFire.y - 190
    tableAnimals[3] = spriteGuyWalk
    tableAnimals[3].isVisible = false
    spriteGuyWalk:play()


    --SEPARATING LINE
    divLine = display.newRect(display.contentWidth*.5, spriteFlyingBird.y - (math.round((spriteFlyingBird.height * spriteFlyingBird.yScale) * .5)) , display.contentWidth, 10)
    divLine:setFillColor(55,55,55,256)
    sceneGroup:insert(divLine)



end



-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase


    

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
        print("SCENE:SHOW.WILL")

    	--LOAD ALL SPRITE STUFF
    	loadSprites(sceneGroupGlobal)
		
		--START THE TIMERS
    	gameListeners("start")


    elseif ( phase == "did" ) then
        composer.removeScene( "sceneMenu", true )
        print("SCENE:SHOW.DID")



        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
        print("SCENE:HIDE.WILL")
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
        print("SCENE:HIDE.DID")


      
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.

	print("SCENE:DESTROY")
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene