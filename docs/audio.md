[← Project home](../README.md) · [Journal index / 日志目录](JOURNAL.md)

> Historical record: rules, counts, tests, and pending work refer to this version, not the current release.
>
> 历史记录：规则、数量、测试与待办均对应当时版本，并非当前发布状态。

# Audio design and resources

# 声音设计与资源

Current rolling is independently synthesized by `tools/prepare_rolling_audio.py`, without reading/excerpting external recordings. Short inharmonic resonances simulate light contact, excluding large landing impacts, sustained white noise, and bass oscillation. Speed controls rate/gain. `tools/make_audio.py` generates other effects/music. Samples are pregenerated 22050 Hz, 16-bit mono PCM, not synthesized live.

当前滚动声由 `tools/prepare_rolling_audio.py` 独立合成，不读取或截取外部录音。用短衰减的非整数倍频率共鸣模拟轻微滚动接触，不加入落地大碰撞、持续白噪声或低音振荡。速度控制播放速率和音量。其他音效与音乐由 `tools/make_audio.py` 生成。采样为 22050 Hz、16-bit、单声道 PCM，预先生成，不在游戏中实时合成。

The CC0 recording used in 0.6.4 remains in `assets/audio-source/` as historical reference, no longer used by current audio or builds.

0.6.4 使用过的 CC0 录音保留在 `assets/audio-source/` 作为历史参考，不再用于当前声音，也不进入游戏构建。

|Sound<br>声音|Trigger rule<br>触发规则|
|---|---|
| Rolling | Loop only while grounded on track and moving; speed changes volume/pitch. Stop still, airborne, in menus, or failed. |
| 滚动 | 仅落在轨道上并移动时循环；速度影响音量与音高，静止、腾空、菜单和失败时停止 |
| Jump / landing | Once at actual takeoff / successful landing. |
| 跳跃 / 落地 | 实际起跳和成功落地各播放一次 |
| Fall | Once on entering the falling state. |
| 掉落 | 进入掉落状态时播放一次 |
| Wall | Collision velocity change must exceed threshold, with at least 0.18 seconds between sounds. |
| 撞墙 | 碰撞导致的速度变化大于阈值才播放，至少间隔 0.18 秒 |
| Charge | Quiet tick for each quarter of JUMP. |
| 蓄跳 | JUMP 每越过一个四分之一刻度给予轻提示 |
| Checkpoint / finish | First checkpoint save or course completion. |
| 检查点 / 终点 | 首次保存检查点或完成关卡时播放 |
| Menu | Short selection/confirmation cues. |
| 菜单 | 选择和确认操作的短提示 |
| Music | Quiet short melody loop, low by default, separately disabled. |
| 音乐 | 安静的短旋律循环，默认低音量，可独立关闭 |

No separate acceleration effect. System pause pauses music and stops rolling/short effects; resuming restores music. Classroom neither loads audio nor includes its directory.

没有单独的加速音效。系统暂停时暂停音乐、停止短音效和滚动声；返回游戏后恢复音乐。课堂配置不加载音频，构建时也不包含音频目录。
