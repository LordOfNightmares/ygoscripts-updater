--D/D/D/D Super-Dimensional Sovereign Emperor Zero Paradox
local m=515958940
local cm=_G["c"..m]
function cm.initial_effect(c)
	--pendulum
	aux.EnablePendulumAttribute(c)
	--scale
	local left=Effect.CreateEffect(c)
	left:SetType(EFFECT_TYPE_SINGLE)
	left:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	left:SetCode(EFFECT_CHANGE_LSCALE)
	left:SetRange(LOCATION_PZONE)
	left:SetValue(cm.scval)
	c:RegisterEffect(left)
	local right=left:Clone()
	right:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(right)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94656263,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_HAND+LOCATION_EXTRA)
	e2:SetCountLimit(1)
	e2:SetCondition(cm.spcon)
	e2:SetTarget(cm.sptg)
	e2:SetOperation(cm.spop)
	c:RegisterEffect(e2)
	--Double
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(cm.dddcon)
	e3:SetOperation(cm.dddop)
	c:RegisterEffect(e3)
	--Copy Scale eff
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41209827,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,m)
	e4:SetTarget(cm.copytg)
	e4:SetOperation(cm.copyop)
	c:RegisterEffect(e4)
	--Use Opponent's scales
    local ge1=Effect.CreateEffect(c)
    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_ADJUST)
    ge1:SetRange(LOCATION_PZONE)
    ge1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
    ge1:SetOperation(cm.stealop)
    c:RegisterEffect(ge1)

end
--Use Opponent's scales
function cm.stealop(e,tp,eg,ep,ev,re,r,rp)
    local tc1=Duel.GetFieldCard(1-tp,LOCATION_PZONE,0)
    local tc2=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
    if not tc1 or not tc2 then return end
    if tc1:GetFlagEffect(m)>0 or tc2:GetFlagEffect(m)>0 then return end
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(1163)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC_G)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_BOTH_SIDE)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCondition(cm.PendCondition)
    e1:SetOperation(cm.PendOperation)
    e1:SetValue(SUMMON_TYPE_PENDULUM)
    e1:SetReset(RESET_EVENT+RESETS_REDIRECT+RESET_TOFIELD+RESET_LEAVE)
    tc1:RegisterEffect(e1)
    tc1:RegisterFlagEffect(m,RESET_EVENT+RESETS_REDIRECT+RESET_TOFIELD+RESET_LEAVE,0,1,tc2:GetFieldID())
    tc2:RegisterFlagEffect(m,RESET_EVENT+RESETS_REDIRECT+RESET_TOFIELD+RESET_LEAVE,0,1,tc1:GetFieldID())
end
function cm.PendCondition(e,c,og)
    if c==nil then return true end
    local tp=e:GetOwnerPlayer()
    local sc1=Duel.GetFieldCard(1-tp,LOCATION_PZONE,0)
    local sc2=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
    local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
    if PENDULUM_CHECKLIST&(0x1<<tp)~=0 and #eset==0 then return false end
    if sc1==nil or sc2==nil then return false end
    local lscale=sc1:GetLeftScale()
    local rscale=sc2:GetRightScale()
    if lscale>rscale then lscale,rscale=rscale,lscale end
    local loc=0
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
    if Duel.GetLocationCountFromEx(tp)>0 then loc=loc+LOCATION_EXTRA end
    if loc==0 then return false end
    local g=nil
    if og then
        g=og:Filter(Card.IsLocation,nil,loc)
    else
        g=Duel.GetFieldGroup(tp,loc,0)
    end
    return g:IsExists(Auxiliary.PConditionFilter,1,nil,e,tp,lscale,rscale,eset)
end
function cm.PendOperation(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
    local lpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,0)
    local rpz=Duel.GetFieldCard(1-tp,LOCATION_PZONE,1)
    local lscale=lpz:GetLeftScale()
    local rscale=rpz:GetRightScale()
    if lscale>rscale then lscale,rscale=rscale,lscale end
    local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
    local tg=nil
    local loc=0
    local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local ft2=Duel.GetLocationCountFromEx(tp)
    local ft=Duel.GetUsableMZoneCount(tp)
    local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
    if ect and ect<ft2 then ft2=ect end
    if Duel.IsPlayerAffectedByEffect(tp,59822133) then
        if ft1>0 then ft1=1 end
        if ft2>0 then ft2=1 end
        ft=1
    end
    if ft1>0 then loc=loc|LOCATION_HAND end
    if ft2>0 then loc=loc|LOCATION_EXTRA end
    if og then
        tg=og:Filter(Card.IsLocation,nil,loc):Filter(Auxiliary.PConditionFilter,nil,e,tp,lscale,rscale,eset)
    else
        tg=Duel.GetMatchingGroup(Auxiliary.PConditionFilter,tp,loc,0,nil,e,tp,lscale,rscale,eset)
    end
    local ce=nil
    local b1=PENDULUM_CHECKLIST&(0x1<<tp)==0
    local b2=#eset>0
    if b1 and b2 then
        local options={1163}
        for _,te in ipairs(eset) do
            table.insert(options,te:GetDescription())
        end
        local op=Duel.SelectOption(tp,table.unpack(options))
        if op>0 then
            ce=eset[op]
        end
    elseif b2 and not b1 then
        local options={}
        for _,te in ipairs(eset) do
            table.insert(options,te:GetDescription())
        end
        local op=Duel.SelectOption(tp,table.unpack(options))
        ce=eset[op+1]
    end
    if ce then
        tg=tg:Filter(Auxiliary.PConditionExtraFilterSpecific,nil,e,tp,lscale,rscale,ce)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    Auxiliary.GCheckAdditional=Auxiliary.PendOperationCheck(ft1,ft2,ft)
    local g=tg:SelectSubGroup(tp,aux.TRUE,true,1,math.min(#tg,ft),ft1,ft2,ft)
    Auxiliary.GCheckAdditional=nil
    if not g then return end
    if ce then
        Duel.Hint(HINT_CARD,0,ce:GetOwner():GetOriginalCode())
        ce:Reset()
    else
        PENDULUM_CHECKLIST=PENDULUM_CHECKLIST|(0x1<<tp)
    end
    sg:Merge(g)
    Duel.HintSelection(Group.FromCards(lpz,rpz))
end
--Copy Scale eff
function cm.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_PZONE) and aux.disfilter1(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.disfilter1,tp,0,LOCATION_PZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,aux.disfilter1,tp,0,LOCATION_PZONE,1,1,nil)
end
function cm.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) 
		and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup()
		and not tc:IsType(TYPE_TOKEN) and not tc:IsType(TYPE_TRAPMONSTER) then
		local cid=c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,1)	
	end
end
--scale
function cm.scval(e,c,tp) 
	local tp=c:GetControler()
    local psL=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
    local psR=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
    if not psR or not psL then return e:GetHandler():GetOriginalLeftScale()	end
	local val=math.abs(psL:GetLeftScale()-psR:GetRightScale())
    if psL==e:GetHandler() then
    	local ef=Effect.CreateEffect(c)
		ef:SetType(EFFECT_TYPE_SINGLE)
		ef:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
		ef:SetCode(EFFECT_CHANGE_RSCALE)
		ef:SetRange(LOCATION_PZONE)
		ef:SetValue(function(e,tp) return Duel.GetFieldCard(tp,LOCATION_PZONE,0):GetLeftScale()	end)
		c:RegisterEffect(ef)
    	return val
    end
    if psR==e:GetHandler() then
    	local ef=Effect.CreateEffect(c)
		ef:SetType(EFFECT_TYPE_SINGLE)
		ef:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
		ef:SetCode(EFFECT_CHANGE_LSCALE)
		ef:SetRange(LOCATION_PZONE)
		ef:SetValue(function(e,tp) return Duel.GetFieldCard(tp,LOCATION_PZONE,1):GetRightScale() end)
		c:RegisterEffect(ef)
    	return val
    end
end
--special summon
function cm.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x10af) and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
    local psL=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
    local psR=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if psR and psL then
		if e:GetHandler():GetLevel()<psL:GetLeftScale(psL)+psR:GetRightScale(psR)then
			return eg:IsExists(cm.cfilter,1,nil,tp)
		end
	end
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13331639,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cm.destg)
	e1:SetOperation(cm.desop)
	c:RegisterEffect(e1)
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--destroy
function cm.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function cm.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep~=tp end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) return Duel.HalfBattleDamage(ep) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(74069667,2))
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end
--Double Atk
function cm.dddfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) 
	and c:IsPreviousSetCard(0x10af) 
	and c:GetPreviousControler()==tp 
	and c:IsPreviousLocation(LOCATION_ONFIELD) 
	and c:IsPreviousPosition(POS_FACEUP)
end
function cm.dddcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.dddfilter,1,nil,tp)
end
function cm.dddop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e)then
		local atk=0
		if c:GetAttack()>0 then
				atk=atk+c:GetAttack()
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end