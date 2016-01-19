AdventCalendarView = class( "AdventCalendarView" )
AdventCalendarView:include( BaseView )
AdventCalendarView.static.controller = "AdventCalendarController"

function AdventCalendarView:OpenDoor( day )
	return self:controllerTransaction( "OpenDoor", day )
end

function AdventCalendarView:GetUses( ) 
	return self.uses or {}
end

function AdventCalendarView:ReceiveUses( uses )
	self.uses = uses
	hook.Run( "AdvCalendar_UpdateUses", uses )
end