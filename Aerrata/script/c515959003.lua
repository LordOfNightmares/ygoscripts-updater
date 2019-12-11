--Spirit of the Crimson Dragon
local m=515959003
local cm=_G["c"..m]
function cm.initial_effect(c)
	--Predraw/Remove
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetOperation(cm.ops)
	c:RegisterEffect(e1)
	--No Disable
	local eb=Effect.CreateEffect(c)
	eb:SetType(EFFECT_TYPE_SINGLE)
	eb:SetCode(EFFECT_CANNOT_TO_DECK)
	eb:SetRange(LOCATION_REMOVED)
	c:RegisterEffect(eb)
	local ec=eb:Clone()
	ec:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(ec)
	local ed=eb:Clone()
	ed:SetCode(EFFECT_CANNOT_TO_GRAVE)
	c:RegisterEffect(ed)
	local ee=eb:Clone()
	ee:SetCode(EFFECT_CANNOT_REMOVE)
	c:RegisterEffect(ee)
end
function cm.ops(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tp=c:GetControler()
	Duel.DisableShuffleCheck()
	--Allzones
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_EXTRA_TOMAIN_KOISHI)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
	-- --force mzone
	-- local e2=Effect.CreateEffect(c)
	-- e2:SetType(EFFECT_TYPE_FIELD)
	-- e2:SetRange(LOCATION_MZONE)
	-- e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	-- e2:SetTargetRange(1,0)
	-- e2:SetTarget(cm.spfilter)
	-- Duel.RegisterEffect(e2,tp)
	Duel.Exile(c,REASON_RULE)
	if c:GetPreviousLocation()==LOCATION_HAND then
		Duel.Draw(c:GetControler(),1,REASON_RULE)
	end
end
function cm.spfilter(e,c,tp,sump,sumtype,sumpos,targetp,se)
	local zone=Duel.GetLinkedZone(tp)
	if c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_MUST_USE_MZONE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetValue(zone)
		e1:SetTarget(function (e,c) return c:IsType(TYPE_FUSION) end)
		c:RegisterEffect(e1)
		return c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA) 
	end
end
--[[local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local exft=Duel.GetLocationCountFromEx(tp)
    Debug.Message(ft)
    Debug.Message(exft)]]

