module (..., package.seeall)
 
----------------------------------------------------------------
-- FUNCTION: CREATE 
----------------------------------------------------------------
function NewEnemy() --Props )
 
        local Group = display.newGroup()
		--Group.x = Props.x
		--Group.y = Props.y
		
		-- initialize group.*
		
        ---------------------------------------------
        -- METHOD: DELETE STICK
        ---------------------------------------------
        --function Group:delete()
		
        --end
        
        ---------------------------------------------
        -- METHOD: MOVE AN OBJECT
        ---------------------------------------------
        --function Group:move(Obj, maxSpeed, rotate)
                --change x,y of obj
				
       -- end
		function Group:test()
			print("hi")
		end
        ---------------------------------------------
        -- GETTER METHODS
        ---------------------------------------------
        --function Group:getDistance() return self.distance    end
        --function Group:getPercent () return self.percent     end
        --function Group:getAngle   () return Ceil(self.angle) end
		--function Group:getMoving  () return Group.beingMoved end
		

        return Group
 
end