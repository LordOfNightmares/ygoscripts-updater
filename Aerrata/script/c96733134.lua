--Supreme king Dragon Odd-eyes
local m=96733134
local cm=_G["c"..m]
function cm.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCost(cm.thcost)
	e1:SetTarget(cm.thtg)
	e1:SetOperation(cm.thop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(cm.hspcost)
	e2:SetTarget(cm.hsptg)
	e2:SetOperation(cm.hspop)
	c:RegisterEffect(e2)
	--double damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cm.damcon)
	e3:SetOperation(cm.damop)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	-- e4:SetHintTiming(0,TIMING_BATTLE_END+TIMING_END_PHASE)
	e4:SetCondition(cm.spcon)
	e4:SetCost(cm.spcost)
	e4:SetTarget(cm.sptg)
	e4:SetOperation(cm.spop)
	c:RegisterEffect(e4)
end
function cm.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0xf8) end
	local sg=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0xf8)
	Duel.Release(sg,REASON_COST)
end
function cm.thfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAttackBelow(1500) and c:IsAbleToHand()
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function cm.rfilter(c,tp)
	return c:IsSetCard(0x20f8) and (c:IsControler(tp) or c:IsFaceup())
end
function cm.fselect(c,tp,rg,sg)
	sg:AddCard(c)
	if sg:GetCount()<2 then
		res=rg:IsExists(cm.fselect,1,sg,tp,rg,sg)
	else
		res=cm.fgoal(tp,sg)
	end
	sg:RemoveCard(c)
	return res
end
function cm.fgoal(tp,sg)
	if sg:GetCount()>0 and Duel.GetMZoneCount(tp,sg)>0 then
		Duel.SetSelectedCard(sg)
		return Duel.CheckReleaseGroup(tp,nil,0,nil)
	else return false end
end
function cm.hspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetReleaseGroup(tp):Filter(cm.rfilter,nil,tp)
	local g=Group.CreateGroup()
	if chk==0 then return rg:IsExists(cm.fselect,1,nil,tp,rg,g) end
	while g:GetCount()<2 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local sg=rg:FilterSelect(tp,cm.fselect,1,1,g,tp,rg,g)
		g:Merge(sg)
	end
	Duel.Release(g,REASON_COST)
end
function cm.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function cm.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function cm.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsType(TYPE_PENDULUM) and tc:GetBattleTarget()~=nil
end
function cm.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev*2)
end
function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE 
	and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) 
end
function cm.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end
function cm.spfilter(c,e,tp)
	if c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() then
		return (c:IsSetCard(0x10f8) or c:IsSetCard(0x20f8)) 
		and c:IsType(TYPE_PENDULUM) and not c:IsCode(m)
	elseif c:IsLocation(LOCATION_GRAVE) then
		return (c:IsSetCard(0x10f8) or c:IsSetCard(0x20f8)) 
		and c:IsType(TYPE_PENDULUM) and not c:IsCode(m)
	end
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.GetLocationCountFromEx(tp,tp,e:GetHandler())>0 
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp))
		or (Duel.GetLocationCount(e:GetHandler():GetControler(),LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(cm.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local exft=Duel.GetLocationCountFromEx(tp)
    local g=Duel.GetMatchingGroup(cm.spfilter,tp,LOCATION_EXTRA,0,nil)
    exft=math.min(2,math.min(ft+exft,math.min(exft,g:GetCount())))
    local totft = ft+exft
    totft=math.min(totft,2)
    if Duel.IsPlayerAffectedByEffect(tp,59822133) then
        totft=1
    end
    local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
    if ect~=nil then et=math.min(totft,ect) end
    local cg=Group.CreateGroup()
    g=Duel.GetMatchingGroup(cm.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    if g:GetCount()~=0 then
    	if g:GetCount()>1 then 
	   		if not Duel.SelectYesNo(tp,aux.Stringid(m,2)) then totft=1 exft=1 end
    	end
        exft = exft - cg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
        if exft <= 0 then
            local exg=g:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
            g:Sub(exg)
        end
        local sg=g:Select(tp,1,1,nil)
        g:RemoveCard(sg:GetFirst())
        cg:Merge(sg)
    end
    if cg:GetCount()<totft then
        exft = exft - cg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
        if exft <= 0 then
            local exg=g:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
            g:Sub(exg)
        end
        local sg=g:Select(tp,1,1,nil)
        cg:Merge(sg)
    end
    local tc=cg:GetFirst()
    while tc do
        local oc = tc
        tc=cg:GetNext()
        if oc:IsLocation(LOCATION_EXTRA) then
            cg:RemoveCard(oc)
            Duel.SpecialSummon(oc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
        end
    end
    if cg:GetCount()>0 then
        Duel.SpecialSummon(cg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
    end
end