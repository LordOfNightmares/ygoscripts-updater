--スキルドレイン
function c82732705.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c82732705.cost)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetLabelObject(e1)
	e2:SetTarget(c82732705.disable)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
end
function c82732705.disable(e,c,tp)
	local val=e:GetLabelObject():GetLabel()
	e:GetHandler():SetHint(CHINT_NUMBER,val)
	return c:IsType(TYPE_EFFECT) and (c:IsLevel(val) or c:IsRank(val) or c:IsLink(val))
end
function c82732705.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	local val=Duel.AnnounceLevel(tp)
	e:SetLabel(val)
end
