EFFECT_FLAG2_AVAILABLE_BD=0x2000000	--战斗破坏确定时效果也适用（纳祭之魔 地狱战士）
--GetID implementation
function GetID()
    local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
    str=string.sub(str,1,string.len(str)-4)
    local cod=_G[str]
    local id=tonumber(string.sub(str,2))
    return cod,id
end
function getID() return GetID() end
function getid() return GetID() end
--MasterRule
local function masterRule(tp)
	--Extra to main
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_EXTRA_TOMAIN_KOISHI)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
	--adjust
	local e2=Effect.GlobalEffect()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetOperation(func_adjustop)
	Duel.RegisterEffect(e2,tp)
	--Link monsters Mr4
    local e7=Effect.GlobalEffect()
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCode(EFFECT_MUST_USE_MZONE)
    e7:SetTargetRange(LOCATION_EXTRA,0)
    e7:SetValue(func_linkcval)
    Duel.RegisterEffect(e7,tp)
    --Extra monsters can't be spsummoned in Extra monster Zone
  	local e8=Effect.GlobalEffect()
    e8:SetType(EFFECT_TYPE_FIELD)
    e8:SetRange(LOCATION_MZONE)
    e8:SetCode(EFFECT_MUST_USE_MZONE)
    e8:SetTargetRange(LOCATION_EXTRA,0)
    e8:SetValue(func_emz)
    Duel.RegisterEffect(e8,tp)
end
function func_emz(e,c,fp,rp,r) 
	if not c:IsType(TYPE_LINK) then 
		return 0x9FFF9F 
	else 
		return 0xff 
	end
end
function func_linkfil(c)
    return c:GetSequence()>4 and c:IsType(TYPE_LINK)
end
function func_linkcval(e,c,fp,rp,r)
	local lval=0x600060
	local mg=Duel.GetMatchingGroup(func_linkfil,tp,LOCATION_MZONE,0,nil)
	if mg and mg:GetCount()>0 then
        local tc = mg:GetFirst()
        while tc do
          lval=tc:GetLinkedZone()|lval
          tc = mg:GetNext()
        end
    end
    if c:IsType(TYPE_LINK) then
        return lval
    else 
        return 0xff
    end
end
function func_rmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
function Auxiliary.extramonsterzonefiter(c)
    return c:GetSequence()>4
end
--pendulum fix for MasterRule
function Auxiliary.PendOperation()
    return  function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
                local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
                local lscale=c:GetLeftScale()
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
                if not Duel.IsExistingMatchingCard(aux.extramonsterzonefiter,tp,LOCATION_MZONE,0,1,nil) then 
                    ft2=ft2-1
                    ft=ft-1
                end
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
                local g=tg:SelectSubGroup(tp,aux.TRUE,true,1,math.min(#tg,ft))
                Auxiliary.GCheckAdditional=nil
                if not g then return end
                if ce then
                    Duel.Hint(HINT_CARD,0,ce:GetOwner():GetOriginalCode())
                    ce:Reset()
                else
                    PENDULUM_CHECKLIST=PENDULUM_CHECKLIST|(0x1<<tp)
                end
                sg:Merge(g)
                Duel.HintSelection(Group.FromCards(c))
                Duel.HintSelection(Group.FromCards(rpz))
            end
end
--MasterRule activation
if Duel.GetFlagEffect(0,515959000)==0 then
    masterRule(0)
    Duel.RegisterFlagEffect(0,515959000,0,0,1)
end
if Duel.GetFlagEffect(1,515959000)==0 then
    masterRule(1)
    Duel.RegisterFlagEffect(1,515959000,0,0,1)
end
