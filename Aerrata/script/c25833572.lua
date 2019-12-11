function c25833572.initial_effect(c)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c25833572.spcon)
	e1:SetOperation(c25833572.spop)
	c:RegisterEffect(e1)
 	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	-- e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCountLimit(1)
	e2:SetTarget(c25833572.target)
	e2:SetOperation(c25833572.operation)
	c:RegisterEffect(e2)
	--indestructible eff
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
function c25833572.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3
		and Duel.CheckReleaseGroup(tp,Card.IsCode,1,nil,25955164)
		and Duel.CheckReleaseGroup(tp,Card.IsCode,1,nil,62340868)
		and Duel.CheckReleaseGroup(tp,Card.IsCode,1,nil,98434877)
end
function c25833572.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g1=Duel.SelectReleaseGroup(tp,Card.IsCode,1,1,nil,25955164)
	local g2=Duel.SelectReleaseGroup(tp,Card.IsCode,1,1,nil,62340868)
	local g3=Duel.SelectReleaseGroup(tp,Card.IsCode,1,1,nil,98434877)
	g1:Merge(g2)
	g1:Merge(g3)
	Duel.Release(g1,REASON_COST)
end
function c25833572.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttackTarget():IsCanBeEffectTarget(e) or 
		Duel.GetTurnPlayer()~=tp and Duel.GetAttacker():IsCanBeEffectTarget(e) end
	if Duel.GetTurnPlayer()~=tp then
		Duel.SetTargetCard(Duel.GetAttacker())
	else
		Duel.SetTargetCard(Duel.GetAttackTarget())
	end
end
function c25833572.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local ops={aux.Stringid(36407615,0),505,1101}
	local op = Duel.SelectOption(tp,table.unpack(ops))
	if op==0 and tc:IsRelateToEffect(e) then
		local atk=e:GetHandler():GetAttack()
		--sanga atk
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(tc:GetAttack())
		e:GetHandler():RegisterEffect(e1)
		--oppo atk
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
	if op==1 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
		if tc:IsRelateToEffect(e) then
			Duel.SendtoHand(tc, nil, REASON_EFFECT)
		end
	end
	if op==2 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		if tc:IsRelateToEffect(e) then
			--spsummon
			Duel.Destroy(tc,REASON_EFFECT)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			g=Duel.SelectMatchingCard(tp,c25833572.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,ev)
			if g:GetCount()>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
		end
	end
end
function c25833572.filter(c,e,tp)
	return c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end