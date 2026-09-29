"""Publish the actual production order and final-course coverage manifest."""
from pathlib import Path
import json
from check_curriculum import lua
root=Path(__file__).resolve().parents[1]
courses=lua.globals().Courses
rows=[]
for n in range(1,len(courses)+1):
    c=courses[n];lua.globals().Curriculum.ensure(c)
    sections=c['sections']
    row=dict(number=n,id=c['id'],name=c['shortName'],chapter=c['chapterName'],review=bool(c['review']),finale=bool(c['finale']),
             encounters=len(sections) if sections else 0,checkpoints=len(c['checkpoints']),tiles=len(c['tiles']),
             length=int(c['goal'][1]-c['start'][1]),mechanisms=len(c['mechanisms'] or []),controls=len(c['pads'] or []),
             sections=[sections[i]['kind'] for i in range(1,len(sections)+1)] if sections else [])
    rows.append(row);lua.globals().Curriculum.release(c)
(root/'tests/curriculum-v0.12.0.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
lines=['# 0.12.0 关卡递进表','','53 关，20 个学习阶段，最后四关为全机制远征。阶段先短关教学／专项练习，再通过累计复习重用以前学过的机制。复习路线中的机关之间留有安全接续路，不把所有机关堆在同一画面。','','| 关卡 | 名称 | 阶段 | 定位 | 挑战段 / 检查点 |','| --- | --- | --- | --- | --- |']
for r in rows:
    role='全机制远征' if r['finale'] else '累计复习' if r['review'] else '教学／专项练习'
    lines.append(f"| {r['number']} | {r['name']} | {r['chapter']} | {role} | {r['encounters'] or '—'} / {r['checkpoints']} |")
lines+=['','## 最后四关','','每关都有：坡道、谷地、窄路、回头弯、跳跃缝隙、小落脚岛、高台，以及定时闸门、消失地板、自动渡板、自动旋转板、移动挡板、弹力护圈、风机、岸边转桥、板上转桥／召回、升降台、手动渡板、可控风机、大炮、传送带、间歇喷气、伸缩桥、双路闸门、磁力机关。','', '道路长度按世界 X 跨度记录，并非最短通关距离或预计用时。四关的顺序、长度和组合不同，后面追加回访挑战。','']
for r in rows[-4:]:
    lines += [f"### {r['number']} / {r['name']}",'',f"{r['encounters']} 段挑战，{r['checkpoints']} 个检查点，{r['mechanisms']} 个场景机关、{r['controls']} 个控制点；世界 X 跨度 {r['length']}。",'', ' → '.join(r['sections']),'']
lines += ['## 存档迁移','','0.11.0 的 48 个旧编号按稳定关卡 ID 映射到新顺序。完成记录、当前关卡、设置及已看教学保留。重建关卡的旧计时不与新长关比较，因此只清除这些地图的旧 best；未改布局的成绩保留。','']
(root/'CAMPAIGN-v0.12.0.md').write_text('\n'.join(lines),encoding='utf-8')
print('Wrote production campaign manifest and chapter table')
