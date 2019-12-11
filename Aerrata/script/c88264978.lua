--Red-Eyes Darkness Metal Dragon
local m=88264978
local cm=_G["c"..m]
function cm.initial_effect(c)
	--spsummon proc
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(cm.hspcon)
	e1:SetOperation(cm.hspop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,m)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cm.spcon)
	e2:SetTarget(cm.sptg)
	e2:GetLabel(e5)
	e2:SetOperation(cm.spop)
	c:RegisterEffect(e2)
	--atkup
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(cm.val)
	c:RegisterEffect(e3)
	--Quick effect
	local e4=e2:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCondition(cm.quickcon)
	c:RegisterEffect(e4)
	--summon success reg Darkness Dragon
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetOperation(cm.spsumsuc)
    c:RegisterEffect(e5)
    e5:SetLabelObject(e4)
end
function cm.spsumsuc(e,tp,eg,ep,ev,re,r,rp)
    if not re or not re:GetHandler():IsCode(96561011) then
        e:GetLabelObject():SetLabel(1)
    else
    	e:GetLabelObject():SetLabel(100)
    end
end
function cm.quickcon(e,tp,eg,ep,ev,re,r,rp) 
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL) and e:GetLabel()==100
end
function cm.spcon(e,tp,eg,ep,ev,re,r,rp) 
	return e:GetLabel()~=100
end
function cm.val(e,c)
	return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x3b)*200
end
function cm.spfilter(c,ft)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToRemoveAsCost()
		and (ft>0 or c:GetSequence()<5)
end
function cm.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return ft>-1 and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_MZONE,0,1,nil,ft)
end
function cm.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cm.spfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cm.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and not c:IsCode(m) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cm.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			-- local e1=Effect.CreateEffect(c)
			-- e1:SetType(EFFECT_TYPE_SINGLE)
			-- e1:SetCode(EFFECT_DISABLE)
			-- e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			-- sc:RegisterEffect(e1,true)
			-- local e2=Effect.CreateEffect(c)
			-- e2:SetType(EFFECT_TYPE_SINGLE)
			-- e2:SetCode(EFFECT_DISABLE_EFFECT)
			-- e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			-- sc:RegisterEffect(e2,true)
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD)
			e5:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			e5:SetValue(1)
			sc:RegisterEffect(e5,true)
			local e6=e5:Clone()
			e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			sc:RegisterEffect(e6,true)
		end
		Duel.SpecialSummonComplete()
	end
end