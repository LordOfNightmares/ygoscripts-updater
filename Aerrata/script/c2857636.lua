function c2857636.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,c2857636.lcheck)
	c:EnableReviveLimit()
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2857636,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,2857636)
	e1:SetCondition(c2857636.descon)
	e1:SetCost(c2857636.descost)
	e1:SetTarget(c2857636.destg)
	e1:SetOperation(c2857636.desop)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58074177,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,2857636)
	e2:SetCost(c2857636.drcost)
	e2:SetCondition(c2857636.drcon)
	e2:SetOperation(c2857636.drop)
	c:RegisterEffect(e2)
end
function c2857636.filter(c)
	return c:GetMutualLinkedGroupCount()>0 and c:IsSetCard(0x112)
end
function c2857636.drcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerCanDraw(tp,1)
end
function c2857636.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local gc=Duel.GetMatchingGroup(c2857636.filter,tp,LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)
	if chk==0 then return Duel.CheckLPCost(tp,1500*gc) end
	Duel.PayLPCost(tp,1500*gc)
	local val= 1500*gc//1000
	e:SetLabel(val)
end
function c2857636.drop(e,tp,eg,ep,ev,re,r,rp)
	local val=e:GetLabel()
	if Duel.IsPlayerCanDraw(tp,1*val) then
		Duel.BreakEffect()
		Duel.Draw(tp,1*val,REASON_EFFECT)
	end
end
function c2857636.lcheck(g,lc)
	return g:GetClassCount(Card.GetCode)==g:GetCount()
end
function c2857636.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c2857636.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c2857636.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if e:GetHandler():GetMutualLinkedGroupCount()>0 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
		e:SetLabel(1)
	else
		e:SetCategory(CATEGORY_DESTROY)
		e:SetLabel(0)
	end
end
function c2857636.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		and e:GetLabel()==1 and Duel.IsPlayerCanDraw(tp,1)
		and Duel.SelectYesNo(tp,aux.Stringid(2857636,1)) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end