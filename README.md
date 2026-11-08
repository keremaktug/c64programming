# Commodore 64 Assembly Programming

The source code of a beginner course on 6502 assembly for the Commodore 64. There are 59 short lessons, and each one adds only one or two new ideas. The course starts with a program that does nothing, and it ends with a complete brick breaker game that has sprites, joystick control and sound.

Every lesson is one file, numbered in order. A video explains each lesson line by line.

[Watch the 47-second trailer](https://youtu.be/l5zhDhl9gwY) · [Start with Lesson 1](https://youtu.be/BWzHGy1zKog) · [View all 59 lessons](https://www.youtube.com/playlist?list=PLExA2XuwkCv0)

## What you need

- [KickAssembler](http://theweb.dk/KickAssembler/) to turn the source into a program. It needs Java.
- [VICE](https://vice-emu.sourceforge.io/), a C64 emulator, to run the program. These lessons use `x64sc`.

## Assemble and run a lesson

```bash
java -jar KickAss.jar 01.first_c64_prog.asm
```

KickAssembler writes `01.first_c64_prog.prg` next to the source. Start it in VICE:

```bash
x64sc 01.first_c64_prog.prg
```

VICE loads the program and starts it on its own, because every lesson begins with `BasicUpstart2`.

Lessons 48 to 59 read a joystick in port 2. You do not need a real joystick: in the VICE settings, you can map a gamepad, or keys on your keyboard, to joystick port 2.

## Lessons

### 1. Your first program and memory

| Lesson | File |
|---|---|
| 1. Your First C64 Program | [01.first_c64_prog.asm](01.first_c64_prog.asm) |
| 2. Printing a Single Character | [02.print_single_character.asm](02.print_single_character.asm) |
| 3. Changing the Character's Color | [03.change_character_color.asm](03.change_character_color.asm) |
| 4. Changing the Background Color | [04.change_background_color.asm](04.change_background_color.asm) |
| 5. Changing the Border Color | [05.change_border_color.asm](05.change_border_color.asm) |

### 2. Registers

| Lesson | File |
|---|---|
| 6. Working with the A Register | [06.working_with_register_a.asm](06.working_with_register_a.asm) |
| 7. The X Register | [07.working_with_register_x.asm](07.working_with_register_x.asm) |
| 8. The Y Register | [08.working_with_register_y.asm](08.working_with_register_y.asm) |
| 9. Incrementing a Register | [09.increment_register.asm](09.increment_register.asm) |
| 10. Decrementing a Register | [10.decrement_register.asm](10.decrement_register.asm) |

### 3. First loops

| Lesson | File |
|---|---|
| 11. A Simple Loop with X | [11.simple_loop_with_x.asm](11.simple_loop_with_x.asm) |
| 12. Characters Side by Side | [12.indexed_addressing.asm](12.indexed_addressing.asm) |
| 13. Printing Ten A's | [13.print_ten_characters.asm](13.print_ten_characters.asm) |
| 14. Printing the Alphabet | [14.print_alphabet.asm](14.print_alphabet.asm) |
| 15. Filling a Screen Row | [15.fill_screen_row.asm](15.fill_screen_row.asm) |

### 4. Memory and constants

| Lesson | File |
|---|---|
| 16. Defining Constants | [16.constants.asm](16.constants.asm) |
| 17. Using .label | [17.labels.asm](17.labels.asm) |
| 18. Your First Variable | [18.first_variable.asm](18.first_variable.asm) |
| 19. Reading and Writing a Variable | [19.read_write_variable.asm](19.read_write_variable.asm) |
| 20. A Counter Program | [20.counter.asm](20.counter.asm) |

### 5. Comparing and deciding

| Lesson | File |
|---|---|
| 21. Comparing with cmp | [21.compare_with_cmp.asm](21.compare_with_cmp.asm) |
| 22. Branching with beq | [22.branch_with_beq.asm](22.branch_with_beq.asm) |
| 23. Another Path with bne | [23.branch_with_bne.asm](23.branch_with_bne.asm) |
| 24. A Loop with cpx | [24.loop_with_cpx.asm](24.loop_with_cpx.asm) |

### 6. Subroutines

| Lesson | File |
|---|---|
| 25. Your First Subroutine | [25.first_subroutine.asm](25.first_subroutine.asm) |
| 26. A Clear Screen Routine | [26.clear_screen_routine.asm](26.clear_screen_routine.asm) |
| 27. A printChar Routine | [27.print_char_routine.asm](27.print_char_routine.asm) |
| 28. Using Several Routines | [28.multiple_routines.asm](28.multiple_routines.asm) |

### 7. Data tables

| Lesson | File |
|---|---|
| 29. Defining Data with .byte | [29.data_with_byte.asm](29.data_with_byte.asm) |
| 30. Your First String | [30.first_string.asm](30.first_string.asm) |
| 31. A Null-Terminated String | [31.null_terminated_string.asm](31.null_terminated_string.asm) |
| 32. A General printString Routine | [32.print_string_routine.asm](32.print_string_routine.asm) |

### 8. Math

| Lesson | File |
|---|---|
| 33. Simple Addition | [33.simple_addition.asm](33.simple_addition.asm) |
| 34. Simple Subtraction | [34.simple_subtraction.asm](34.simple_subtraction.asm) |
| 35. Simple Coordinates | [35.simple_coordinates.asm](35.simple_coordinates.asm) |

### 9. User input

| Lesson | File |
|---|---|
| 36. Reading the Keyboard | [36.read_keyboard.asm](36.read_keyboard.asm) |
| 37. A Key Changes the Border | [37.key_changes_border.asm](37.key_changes_border.asm) |
| 38. A Moving Character | [38.moving_character.asm](38.moving_character.asm) |

### 10. Your first game

| Lesson | File |
|---|---|
| 39. Moving with WASD | [39.wasd_movement.asm](39.wasd_movement.asm) |
| 40. Mini Project: Catch the Star | [40.catch_the_star.asm](40.catch_the_star.asm) |

### 11. Sprites

| Lesson | File |
|---|---|
| 41. Your First Sprite | [41.first_sprite.asm](41.first_sprite.asm) |
| 42. Sprite Color | [42.sprite_color.asm](42.sprite_color.asm) |
| 43. Two Sprites | [43.two_sprites.asm](43.two_sprites.asm) |
| 44. A Moving Sprite | [44.moving_sprite.asm](44.moving_sprite.asm) |
| 45. A Sprite Across the Whole Screen | [45.full_width_sprite.asm](45.full_width_sprite.asm) |

### 12. Multicolor sprites

| Lesson | File |
|---|---|
| 46. A Multicolor Sprite | [46.multicolor_sprite.asm](46.multicolor_sprite.asm) |
| 47. Shared Colors | [47.shared_colors.asm](47.shared_colors.asm) |

### 13. Joystick

| Lesson | File |
|---|---|
| 48. Reading the Joystick | [48.read_joystick.asm](48.read_joystick.asm) |
| 49. Joystick Directions | [49.joystick_directions.asm](49.joystick_directions.asm) |
| 50. Flying a Sprite with the Joystick | [50.joystick_sprite.asm](50.joystick_sprite.asm) |
| 51. The Fire Button | [51.joystick_fire.asm](51.joystick_fire.asm) |

### 14. Final project: Brick Breaker

The game is built in eight steps. Each file is the whole game so far.

| Lesson | File |
|---|---|
| 52. The Paddle | [52.paddle.asm](52.paddle.asm) |
| 53. A Bouncing Ball | [53.bouncing_ball.asm](53.bouncing_ball.asm) |
| 54. Paddle Collision | [54.paddle_collision.asm](54.paddle_collision.asm) |
| 55. The Bricks | [55.draw_bricks.asm](55.draw_bricks.asm) |
| 56. Brick Collision | [56.brick_collision.asm](56.brick_collision.asm) |
| 57. Score and Lives | [57.score_and_lives.asm](57.score_and_lives.asm) |
| 58. Sound Effects | [58.sound_effects.asm](58.sound_effects.asm) |
| 59. Title Screen and Restart | [59.brick_breaker.asm](59.brick_breaker.asm) |

`59.brick_breaker.asm` is the finished game.

## Extra: Rocky

[rocky/](rocky/) is a small boxing game, made after the course with the same tools. It has a bitmap title screen with a raster effect, a ring scene and two boxers made of sprites.
