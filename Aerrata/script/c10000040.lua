--Holactie
function c10000040.initial_effect(c)
	c:EnableReviveLimit()
	--searched check
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EVENT_TO_HAND)
    e0:SetCondition(c10000040.odrcon)
    e0:SetOperation(c10000040.odrop)
    c:RegisterEffect(e0)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c10000040.spcon)
	e1:SetOperation(c10000040.spop)
	c:RegisterEffect(e1)
	--spsummon condition
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	--win
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(c10000040.winop)
	c:RegisterEffect(e4)
	--tohand
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(39913299,0))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_HAND)
	e5:SetCountLimit(1,10000040+EFFECT_COUNT_CODE_DUEL)
	e5:SetCost(c10000040.thcost)
	e5:SetTarget(c10000040.thtg)
	e5:SetOperation(c10000040.thop)
	c:RegisterEffect(e5)
end
function c10000040.odrcon(e,tp,eg,ep,ev,re,r,rp)
    return re and re:GetHandler():IsCode(39913299)
end
function c10000040.odrop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RegisterFlagEffect(10000040,RESET_EVENT+RESETS_REDIRECT,0,1)
end
function c10000040.spfilter(c,code)
	local code1,code2=c:GetOriginalCodeRule()
	return code1==code or code2==code
end
function c10000040.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if c:GetFlagEffect(10000040)~=0 and Duel.IsEnvironment(269012) then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3
				and Duel.CheckReleaseGroup(tp,c10000040.spfilter,1,nil,10000000)
				and Duel.CheckReleaseGroup(tp,c10000040.spfilter,1,nil,10000010)
				and Duel.CheckReleaseGroup(tp,c10000040.spfilter,1,nil,10000020)
	else
		return false
	end
	
end
function c10000040.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g1=Duel.SelectReleaseGroup(tp,c10000040.spfilter,1,1,nil,10000000)
	local g2=Duel.SelectReleaseGroup(tp,c10000040.spfilter,1,1,nil,10000010)
	local g3=Duel.SelectReleaseGroup(tp,c10000040.spfilter,1,1,nil,10000020)
	g1:Merge(g2)
	g1:Merge(g3)
	Duel.Release(g1,REASON_COST)

end
function c10000040.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_CREATORGOD=0x13
	local p=e:GetHandler():GetSummonPlayer()
	Duel.Win(p,WIN_REASON_CREATORGOD)
end
function c10000040.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function c10000040.thfilter(c)
	return c:IsRace(RACE_DEVINE) and c:IsAbleToHand() and not c:IsCode(10000080)
end
function c10000040.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c10000040.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c10000040.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c10000040.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
