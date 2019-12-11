--Starving Venemy Dragon
local m=515958941
local cm=_G["c"..m]
function cm.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,cm.ffilter,2,false)
	aux.EnablePendulumAttribute(c,false)
	--counter mzone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22070401,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(cm.ctmcon)
	e1:SetTarget(cm.cttg)
	e1:SetOperation(cm.ctop)
	c:RegisterEffect(e1)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(cm.atkval)
	c:RegisterEffect(e2)
	--copy effects
 	local e3=Effect.CreateEffect(c)
 	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_MZONE)	
	e3:SetOperation(cm.operation)
	c:RegisterEffect(e3)
	--reduce
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(22070401,3))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetRange(LOCATION_PZONE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e4:SetCountLimit(1)
	e4:SetCondition(cm.rdcon)
	e4:SetOperation(cm.rdop)
	c:RegisterEffect(e4)
	--counter pzone
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_QUICK_F)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCategory(CATEGORY_COUNTER)
	e5:SetDescription(aux.Stringid(22070401,0))
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetRange(LOCATION_PZONE)
	e5:SetCondition(cm.ctcon)
	e5:SetTarget(cm.cttg)
	e5:SetOperation(cm.ctop)
	c:RegisterEffect(e5)
	--pendulum
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(22070401,2))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(cm.pencon)
	e6:SetTarget(cm.pentg)
	e6:SetOperation(cm.penop)
	c:RegisterEffect(e6)
end
function cm.rdcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetBattleDamage(tp)>0
end
function cm.rdop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetOperation(cm.damop)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end
function cm.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,0)
end
function cm.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK)
end
function cm.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(Card.IsPreviousLocation,nil,LOCATION_ONFIELD)>0
end
function cm.ctmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(m)==0
end
function cm.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x104f,1) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x104f,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1041,1)
end
function cm.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		e:GetHandler():RegisterFlagEffect(m,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,2)
		tc:AddCounter(0x104f,1)
	end	
end
function cm.atkval(e,c)
	return math.floor(Duel.GetCounter(0,1,1,0x104f)+Duel.GetCounter(0,1,1,0x1041))*100
end
function cm.counterfilter(c)
	return math.floor(c:GetCounter(0x104f)+c:GetCounter(0x1041))>0 
	and not c:IsSetCard(0x576) and not c:IsSetCard(0x1050) 
	and  c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TOKEN) and not c:IsType(TYPE_TRAPMONSTER)
end

function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(cm.counterfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	g:Remove(cm.codefilterchk,nil,e:GetHandler())
	if c:IsFacedown() or g:GetCount()<=0 then return end
	repeat
		local tc=g:GetFirst()
		local code=tc:GetOriginalCode()
		local cid=c:CopyEffect(code,RESET_EVENT+0x1fe0000,1)
		c:RegisterFlagEffect(code,RESET_EVENT+0x1fe0000,0,0)
		local e0=Effect.CreateEffect(c)
		e0:SetCode(m)
		e0:SetLabel(code)
		e0:SetReset(RESET_EVENT+0x1fe0000)
		c:RegisterEffect(e0,true)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ADJUST)
		e1:SetRange(LOCATION_MZONE)
		e1:SetLabel(cid)
		e1:SetLabelObject(e0)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetOperation(cm.resetop)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		c:RegisterEffect(e1,true)
		g:Remove(cm.codefilter,nil,code)
	until g:GetCount()<=0
end
function cm.codefilter(c,code)
	return c:GetOriginalCode()==code and cm.counterfilter(c)
end
function cm.codefilterchk(c,sc)
	return sc:GetFlagEffect(c:GetOriginalCode())>0
end
function cm.resetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(cm.counterfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if not g:IsExists(cm.codefilter,1,nil,e:GetLabelObject():GetLabel()) or c:IsDisabled() then
		c:ResetEffect(e:GetLabel(),RESET_COPY)
		c:ResetFlagEffect(e:GetLabelObject():GetLabel())
	end
end
function cm.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function cm.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function cm.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
