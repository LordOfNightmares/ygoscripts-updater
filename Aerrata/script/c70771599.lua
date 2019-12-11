--Supreme King Servant Dragon Clear Wing
local m=70771599
local cm=_G["c"..m]
function cm.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(cm.matfilter),1)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(cm.spcon)
	e1:SetOperation(cm.spop)
	c:RegisterEffect(e1)
	--negate all
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(cm.descon)
	e2:SetTarget(cm.destg)
	e2:SetOperation(cm.desop)
	c:RegisterEffect(e2)
	--destroy and damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(cm.ddcon)
	e3:SetTarget(cm.ddtg)
	e3:SetOperation(cm.ddop)
	c:RegisterEffect(e3)
	--special summongy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(cm.spcost3)
	e4:SetTarget(cm.sptg3)
	e4:SetOperation(cm.spop3)
	c:RegisterEffect(e4)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m,3))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	-- e4:SetHintTiming(0,TIMING_BATTLE_END+TIMING_END_PHASE)
	e4:SetCondition(cm.spcon2)
	e4:SetCost(cm.spcost2)
	e4:SetTarget(cm.sptg2)
	e4:SetOperation(cm.spop2)
	c:RegisterEffect(e4)
end
----Important
function cm.SelectUnselectLoop(c,sg,mg,e,tp,minc,maxc,rescon)
	local res
	if sg:GetCount()>=maxc then return false end
	sg:AddCard(c)
	if sg:GetCount()<minc then
		res=mg:IsExists(cm.SelectUnselectLoop,1,sg,sg,mg,e,tp,minc,maxc,rescon)
	elseif sg:GetCount()<maxc then
		res=(not rescon or rescon(sg,e,tp,mg)) or mg:IsExists(cm.SelectUnselectLoop,1,sg,sg,mg,e,tp,minc,maxc,rescon)
	else
		res=(not rescon or rescon(sg,e,tp,mg))
	end
	sg:RemoveCard(c)
	return res
end
function cm.SelectUnselectGroup(g,e,tp,minc,maxc,rescon,chk,seltp,hintmsg,cancelcon,breakcon)
	local minc=minc and minc or 1
	local maxc=maxc and maxc or 99
	if chk==0 then return g:IsExists(cm.SelectUnselectLoop,1,nil,Group.CreateGroup(),g,e,tp,minc,maxc,rescon) end
	local hintmsg=hintmsg and hintmsg or 0
	local sg=Group.CreateGroup()
	while true do
		local cancel=sg:GetCount()>=minc and (not cancelcon or cancelcon(sg,e,tp,g))
		local mg=g:Filter(cm.SelectUnselectLoop,sg,sg,g,e,tp,minc,maxc,rescon)
		if (breakcon and breakcon(sg,e,tp,mg)) or mg:GetCount()<=0 or sg:GetCount()>=maxc then break end
		Duel.Hint(HINT_SELECTMSG,seltp,hintmsg)
		local tc=mg:SelectUnselect(sg,seltp,cancel,cancel)
		if not tc then break end
		if sg:IsContains(tc) then
			sg:RemoveCard(tc)
		else
			sg:AddCard(tc)
		end
	end
	return sg
end
---------------
function cm.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_PENDULUM)
end
function cm.spfilter(c,tp)
	return c:IsControler(1-tp) and c:IsType(TYPE_SYNCHRO) 
end
function cm.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf8)
end
function cm.rescon(sg,e,tp,mg)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,sg,c)>0
	else
		return cm.chkfmmz(1)(sg,e,tp,mg)
	end
end
function cm.chkfmmz(sumcount)
	return	function(sg,e,tp,mg)
				return sg:FilterCount(cm.mzliter,nil,tp)+Duel.GetLocationCount(tp,LOCATION_MZONE)>=sumcount
			end
end
function cm.mzliter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 and c:IsControler(tp)
end
function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetReleaseGroup(tp):Filter(Card.IsSetCard,nil,0xf8)
	return eg:IsExists(cm.spfilter,1,nil,tp) 
	and Duel.IsExistingMatchingCard(cm.cfilter,tp,LOCATION_MZONE,0,2,nil)
	and g:GetCount()>1 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,true)
	and cm.SelectUnselectGroup(g,e,tp,2,2,cm.rescon,0)
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetReleaseGroup(tp):Filter(Card.IsSetCard,nil,0xf8)
	if g:GetCount()>1 
		and cm.SelectUnselectGroup(g,e,tp,2,2,cm.rescon,0) 
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,true) 
		and Duel.SelectYesNo(tp,aux.Stringid(m,4)) then
		local sg=cm.SelectUnselectGroup(g,e,tp,2,2,cm.rescon,1,tp,HINTMSG_RELEASE)
		Duel.Release(sg,REASON_COST)
		Duel.SpecialSummon(c,SUMMON_TYPE_SYNCHRO,tp,tp,false,true,POS_FACEUP)
		c:CompleteProcedure()
	end
end
function cm.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cm.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function cm.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
function cm.ddcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle()
end
function cm.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetBaseAttack())
end
function cm.ddop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if c:IsFaceup() and c:IsRelateToBattle() and bc:IsFaceup() and bc:IsRelateToBattle() and Duel.Destroy(bc,REASON_EFFECT)>0 then
		local dam=bc:GetBaseAttack()
		if dam>0 then Duel.Damage(p,dam,REASON_EFFECT) end
	end
end
function cm.spcost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetReleaseGroup(tp):Filter(Card.IsSetCard,nil,0x20f8)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and g:GetCount()>1 
		and cm.SelectUnselectGroup(g,e,tp,2,2,cm.chkfmmz(1),0) end
	local sg=cm.SelectUnselectGroup(g,e,tp,2,2,cm.chkfmmz(1),1,tp,HINTMSG_RELEASE)
	Duel.Release(sg,REASON_COST)
end
function cm.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function cm.spop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function cm.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
function cm.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.SendtoDeck(c,nil,0,REASON_COST)
end
function cm.spfilter2(c,e,tp)
	return c:IsLocation(LOCATION_EXTRA)
	and c:IsFaceup() 
	and c:IsSetCard(0x20f8)	
	and c:IsType(TYPE_PENDULUM) 
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function cm.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCountFromEx(tp,tp,e:GetHandler())>0
		and Duel.IsExistingMatchingCard(cm.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cm.spop2(e,tp,eg,ep,ev,re,r,rp)
	local ft=math.min(Duel.GetLocationCountFromEx(tp),2)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	if ect~=nil then ft=math.min(ft,ect) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cm.spfilter2,tp,LOCATION_EXTRA,0,1,ft,nil,e,tp)
	local tc=g:GetFirst()
	while tc do
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		tc=g:GetNext()
	end
end