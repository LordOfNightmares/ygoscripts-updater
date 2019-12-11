--Odd-Eyes Phantasma Dragon 
function c21770839.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--to hand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(21770839,0))
	e0:SetCategory(CATEGORY_TOHAND)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCountLimit(1,21770839)
	e0:SetCost(c21770839.thcost)
	e0:SetTarget(c21770839.thtg)
	e0:SetOperation(c21770839.thop)
	c:RegisterEffect(e0)
	--overscale
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(21770839)
	e1:SetCondition(c21770839.spcon)
	c:RegisterEffect(e1)
	--attack down
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetDescription(aux.Stringid(21770839,2))
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c21770839.atkcon)
	e2:SetOperation(c21770839.atkop)
	c:RegisterEffect(e2)
end
function Auxiliary.PConditionFilter(c,e,tp,lscale,rscale,eset)
	local lv=0
	if c.pendulum_level then
		lv=c.pendulum_level
	else
		lv=c:GetLevel()
	end
	local bool=Auxiliary.PendulumSummonableBool(c)
	return (c:IsLocation(LOCATION_HAND) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
		and (lv>lscale and lv<rscale or c:IsHasEffect(21770839)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,bool,bool)
		and not c:IsForbidden()
		and (PENDULUM_CHECKLIST&(0x1<<tp)==0 or Auxiliary.PConditionExtraFilter(c,e,tp,lscale,rscale,eset))
end
function c21770839.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c21770839.thfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
function c21770839.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21770839.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function c21770839.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c21770839.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c21770839.spfilter(c)
	return c:IsSetCard(0x99) and c:IsFaceup()
end
function c21770839.spcon(e)
	return Duel.IsExistingMatchingCard(c21770839.spfilter,tp,LOCATION_EXTRA,0,1,nil)
end
function c21770839.atkfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end
function c21770839.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local d=c:GetBattleTarget()
	local gc=Duel.GetMatchingGroupCount(c21770839.atkfilter,tp,LOCATION_EXTRA,0,nil)
	return c==Duel.GetAttacker() and d and d:IsFaceup() and not d:IsControler(tp) and gc>0
end
function c21770839.atkop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttacker():GetBattleTarget()
	local gc=Duel.GetMatchingGroupCount(c21770839.atkfilter,tp,LOCATION_EXTRA,0,nil)
	if d:IsRelateToBattle() and d:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(-gc*1000)
		d:RegisterEffect(e1)
	end
end