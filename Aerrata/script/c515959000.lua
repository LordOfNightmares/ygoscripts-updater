local m=515959000
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
    --check for negations
    if not cm.global_check then
        cm.global_check=true
        local e2=Effect.GlobalEffect()
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_CHAINING)
        e2:SetTargetRange(1,0)
        e2:SetOperation(cm.activate)
        Duel.RegisterEffect(e2,0)
    end
    --Activate
    local e3=Effect.CreateEffect(c) 
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_CANNOT_ACTIVATE)
    e3:SetRange(0xff,0)
    e3:SetTargetRange(1,0)
    e3:SetValue(cm.limval)
    Duel.RegisterEffect(e3,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if (re:IsActiveType(TYPE_MONSTER) 
			or (re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)))  
		and (re:IsHasCategory(CATEGORY_DISABLE_SUMMON) 
			or re:IsHasCategory(CATEGORY_NEGATE)
			or re:IsHasCategory(CATEGORY_DISABLE)) then
    	Duel.RegisterFlagEffect(rp,m,RESET_PHASE+PHASE_END,0,0)
	end
end
function cm.limval(e,re,rp,tp)
	local turn=Duel.GetTurnCount()
	if (turn & 1) == 0 then val=math.floor(turn/2) else val=math.floor(turn/2)+1 end
    return (re:IsActiveType(TYPE_MONSTER) or 
    	(re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)))  
    and re:IsHasCategory(CATEGORY_NEGATE+CATEGORY_DISABLE+CATEGORY_DISABLE_SUMMON)
    and (Duel.GetFlagEffect(rp,m) >= val) and val<=4 
end
function cm.tofield(e,c,sump,sumtype,sumpos,targetp,se)
	Debug.Message(c:GetCode())
    return c:IsType(TYPE_FUSION)
end
function cm.ops(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- Duel.ConfirmCards(1-tp,c)
	Duel.DisableShuffleCheck()
	Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
	--10000000
	-- if Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_EXTRA_TOMAIN_KOISHI)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
	--adjust
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetOperation(cm.adjustop)
	Duel.RegisterEffect(e2,tp)
	--cannot summon,spsummon,flipsummon
	-- local e4=Effect.CreateEffect(c)
	-- e4:SetType(EFFECT_TYPE_FIELD)
	-- e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	-- e4:SetTargetRange(1,0)
	-- e4:SetTarget(cm.sumlimit)
	-- Duel.RegisterEffect(e4,tp)
	-- local e5=e4:Clone()
	-- e5:SetCode(EFFECT_CANNOT_SUMMON)
	-- Duel.RegisterEffect(e5,tp)
	-- local e6=e4:Clone()
	-- e6:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- Duel.RegisterEffect(e6,tp)
	--Link monsters Mr4
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCode(EFFECT_MUST_USE_MZONE)
    e7:SetTargetRange(LOCATION_EXTRA,0)
    e7:SetValue(cm.linkcval)
    Duel.RegisterEffect(e7,tp)
    --Extra monsters can't be spsummoned in Extra monster Zone
  	local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_FIELD)
    e8:SetRange(LOCATION_MZONE)
    e8:SetCode(EFFECT_MUST_USE_MZONE)
    e8:SetTargetRange(LOCATION_EXTRA,0)
    e8:SetValue(cm.emz)
    Duel.RegisterEffect(e8,tp)
	-- end
	Duel.Exile(c,REASON_RULE)
	-- if c:GetPreviousLocation()==LOCATION_HAND then
	-- 	Duel.Draw(c:GetControler(),1,REASON_RULE)
	-- end
end
function cm.emz(e,c,fp,rp,r) 
	if not c:IsType(TYPE_LINK) then 
		return 0x9FFF9F 
	else 
		return 0xff 
	end
end
function cm.linkfil(c)
    return c:GetSequence()>4 and c:IsType(TYPE_LINK)
end
function cm.linkcval(e,c,fp,rp,r)
	local lval=0x600060
	local mg=Duel.GetMatchingGroup(cm.linkfil,tp,LOCATION_MZONE,0,nil)
	if mg and mg:GetCount()>0 then
        local tc = mg:GetFirst()
        while tc do
          lval=tc:GetLinkedZone()|lval
          tc = mg:GetNext()
        end
    end
    if c:IsType(TYPE_LINK) then
        return lval
    elseif c:IsType(TYPE_PENDULUM) then
    	return 0x1f
    else 
        return 0xff
    end
end
function cm.rmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- function cm.sumlimit(e,c,sump,sumtype,sumpos,targetp)
-- 	if sumpos and (sumpos&POS_FACEDOWN)>0 then return false end
--     local tp=sump
--     if targetp then tp=targetp end
-- 	return Duel.IsExistingMatchingCard(cm.rmfilter,tp,LOCATION_MZONE,0,3,c) and c:IsType(TYPE_LINK)
-- end
-- function cm.adjustop(e,tp,eg,ep,ev,re,r,rp)
-- 	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_LINK)
-- 	local ct=g:GetCount()-3
-- 	if ct>0 then
-- 	    local sg=g:Select(tp,ct,ct,nil)
-- 	    Duel.SendtoGrave(sg,REASON_RULE)
-- 	    Duel.Readjust()
-- 	end
-- end
