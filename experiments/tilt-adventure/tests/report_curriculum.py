"""Publish the actual production order and final-course coverage manifest."""
from pathlib import Path
import json,re
from check_curriculum import lua
root=Path(__file__).resolve().parents[1]
version=re.search(r'^version=(.+)$',(root/'source/pdxinfo').read_text(),re.M).group(1)
courses=lua.globals().Courses
rows=[]
for n in range(1,len(courses)+1):
    c=courses[n];lua.globals().Curriculum.ensure(c)
    sections=c['sections']
    row=dict(number=n,id=c['id'],name=c['shortName'],chapter=c['chapterName'],review=bool(c['review']),finale=bool(c['finale']),
             encounters=len(sections) if sections else 0,checkpoints=len(c['checkpoints']),tiles=len(c['tiles']),
             length=int(c['goal'][1]-c['start'][1]),mechanisms=len(c['mechanisms'] or []),controls=len(c['pads'] or []),cannons=sum(p['kind']=='cannon' for _,p in (c['pads'] or {}).items()),revisedLesson=bool(c['revisedLesson']),
             sections=[sections[i]['kind'] for i in range(1,len(sections)+1)] if sections else [])
    rows.append(row);lua.globals().Curriculum.release(c)
(root/f'tests/curriculum-v{version}.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
lines=[f'# {version} 关卡递进表','','53 关，20 个学习阶段，最后四关为全机制远征。复习先应用刚学的机制，再连接相关技能；保留以前学过的机制，但不再每次从同一谷地开始重走相同顺序。复习接续路缩至 64 单位，保留安静检查点；完整远征仍用 128 单位间隔。','','| 关卡 | 名称 | 阶段 | 定位 | 挑战段 / 检查点 |','| --- | --- | --- | --- | --- |']
for r in rows:
    role='全机制远征' if r['finale'] else '累计复习' if r['review'] else '教学／专项练习'
    lines.append(f"| {r['number']} | {r['name']} | {r['chapter']} | {role} | {r['encounters'] or '—'} / {r['checkpoints']} |")
lines+=['','## 最后四关','','每关都有：坡道、谷地、窄路、回头弯、跳跃缝隙、小落脚岛、高台，以及定时闸门、消失地板、自动渡板、自动旋转板、移动挡板、弹力护圈、风机、岸边转桥、板上转桥／召回、升降台、手动渡板、可控风机、大炮、传送带、间歇喷气、伸缩桥、双路闸门、磁力机关。','', '道路长度按世界 X 跨度记录，并非最短通关距离或预计用时。四关的顺序、长度和组合不同，后面追加回访挑战。','']
for r in rows[-4:]:
    lines += [f"### {r['number']} / {r['name']}",'',f"{r['encounters']} 段挑战，{r['checkpoints']} 个检查点，{r['mechanisms']} 个场景机关、{r['controls']} 个控制点，其中 {r['cannons']} 门炮；世界 X 跨度 {r['length']}。",'', ' → '.join(r['sections']),'']
lines += ['## 存档迁移','','0.11.0 的 48 个旧编号按稳定关卡 ID 映射到新顺序。完成记录、当前关卡、设置及已看教学保留。重建关卡的旧计时不与新长关比较，因此只清除这些地图的旧 best；未改布局的成绩保留。','']
lines += ['## 本轮全关处理','','| 关卡 | 检查结论 / 处理 |','| --- | --- |']
lesson_notes={1:'加宽第一条弯路，先练倾斜与回正；实际倾斜动力学通关。',4:'加宽下坡后的平面转角，保留刹车练习；实际倾斜动力学通关。',27:'岸边召回后改走南出口，与第一次板上转向的北出口区分。',30:'折返端点置于平坦台地；实际倾斜动力学通关。',36:'炮口初始偏离目标，必须瞄准；延长接收台以供刹车。'}
for r in rows:
    if r['number'] in lesson_notes:note=lesson_notes[r['number']]
    elif r['review']:note='重排为新技能开场及关联复习，调整空间布局／机关组合；仍覆盖全部已学机制。'
    elif r['finale']:note='检查全部机制覆盖、连续通关和重复段落；51–53 加入斜向炮台与落地缓冲，弯道平台化。'
    else:note='保留独立教学／专项任务；已纳入全关连通性、教学顺序、原生画面与真机抽测范围。'
    lines.append(f"| {r['number']} / {r['name']} | {note} |")
lines += ['', '重复检查的边界：相同机关、部分基本道路形状仍可用于练习；不把这些基础构件宣称为每次全新。重点修复整段照搬、重复开场、无须瞄准的炮台、坡弯的非预期推力与缺少新任务的复习。连通图检查不等同于手持完成所有关卡。', '', '本轮迁移到 campaignRevision 4，完成状态与当前关卡不变；仅清理改过布局的关卡最佳时间。','']
(root/f'CAMPAIGN-v{version}.md').write_text('\n'.join(lines),encoding='utf-8')
print('Wrote production campaign manifest and chapter table')
