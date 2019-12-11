--ラーの翼神竜－不死鳥
function c10000090.initial_effect(c)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10000090,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c10000090.spcon1)
	e2:SetTarget(c10000090.sptg1)
	e2:SetOperation(c10000090.spop1)
	c:RegisterEffect(e2)
	--immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c10000090.efilter)
	c:RegisterEffect(e3)
	--tograve
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(10000090,1))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c10000090.tgcost)
	e4:SetTarget(c10000090.tgtg)
	e4:SetOperation(c10000090.tgop)
	c:RegisterEffect(e4)
	--spsummon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(10000090,2))
	e5:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,10000090)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetTarget(c10000090.sptg2)
	e5:SetOperation(c10000090.spop2)
	c:RegisterEffect(e5)
	--tribute special summon
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_SPSUMMON_PROC)
	e6:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e6:SetRange(LOCATION_HAND)
	e6:SetCondition(c10000090.hspcon)
	e6:SetOperation(c10000090.hspop)
	c:RegisterEffect(e6)
end
function c10000090.hspfilter1(c,g,ft)
	local rg=Group.FromCards(c)
	local ct=ft
	if c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then ct=ct+1 end
	return c:IsAttribute(ATTRIBUTE_DEVINE) and g:IsExists(c10000090.hspfilter2,1,rg,g,rg,ft)
end
function c10000090.hspfilter2(c,g,rg,ft)
	local rg2=rg:Clone()
	rg2:AddCard(c)
	local ct=ft
	if c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then ct=ct+1 end
	return c:IsAttribute(ATTRIBUTE_DEVINE) and g:IsExists(c10000090.hspfilter3,1,rg2,ft)
end
function c10000090.hspfilter3(c,ft)
	local ct=ft
	if c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then ct=ct+1 end
	return c:IsAttribute(ATTRIBUTE_DEVINE) and c:IsCode(10000010) and ct>0
end
function c10000090.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<-2 then return false end
	local g=Duel.GetReleaseGroup(tp)
	return g:IsExists(c10000090.hspfilter1,1,nil,g,ft)
end
function c10000090.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetReleaseGroup(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g1=g:FilterSelect(tp,c10000090.hspfilter1,1,1,nil,g,ft)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g2=g:FilterSelect(tp,c10000090.hspfilter2,1,1,g1,g,g1,ft)
	g1:Merge(g2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g3=g:FilterSelect(tp,c10000090.hspfilter3,1,1,g1,ft)
	g1:Merge(g3)
	if Duel.Release(g1,REASON_COST+REASON_MATERIAL) then 
			local e1=Effect.CreateEffect(c)
			e1:SetCategory(CATEGORY_TOGRAVE)
			e1:SetDescription(aux.Stringid(4779091,1))
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
			e1:SetRange(LOCATION_MZONE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
			e1:SetCode(EVENT_SPSUMMON_SUCCESS)
			e1:SetTarget(c10000090.desalltg)
			e1:SetOperation(c10000090.desallop)
			e1:SetCountLimit(1)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			c:RegisterEffect(e1)
			--spsummon limit
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetRange(0xff)
			e2:SetCode(EFFECT_CANNOT_SUMMON)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
			e2:SetTargetRange(1,0)
			e2:SetTarget(c10000090.sumlimit)
			e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
			c:RegisterEffect(e2)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			c:RegisterEffect(e3)
			local e4=e2:Clone()
			e4:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
			c:RegisterEffect(e4)
	end
end
function c10000090.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsLocation(LOCATION_GRAVE)
end
function c10000090.desalltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
		
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
function c10000090.desallop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	Duel.SendtoGrave(g,REASON_EFFECT)
end
function c10000090.cfilter(c,tp)
	return c:IsCode(10000010) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function c10000090.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c10000090.cfilter,1,nil,tp)
end
function c10000090.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetChainLimit(aux.FALSE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c10000090.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end

function c10000090.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function c10000090.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function c10000090.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
function c10000090.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function c10000090.spfilter(c,e,tp)
	return c:IsCode(10000080) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c10000090.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function c10000090.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c10000090.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end