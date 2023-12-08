breed [ nests nest]
breed [ants ant]
breed [food-sources food-source]
breed [obstacles obstacle]


patches-own [
  ppheromones
  nest-scent
]

globals [
  nest-x
  nest-y
  direction
  food-stock
]
ants-own[
  has-food
]
food-sources-own[

  nb-links
]
;======================;
;---Setup procedures---;
;======================;

to setup
  clear-all
  setup-nest
  setup-ants
  setup-food-sources
  setup-patches
  setup-obstacles
  setup-pheromones
  reset-ticks
end

to setup-patches
  ask patches [
    set pcolor 65
    set nest-scent 200 - distancexy nest-x nest-y
  ]
end

to setup-nest
  set nest-x random-xcor
  set nest-y random-ycor
  create-nests 1 [
    set shape "circle 2"
    setxy nest-x nest-y
    set size 2
    set color brown - 2
    set food-stock 0
  ]
end

to setup-ants
  set-default-shape ants "ant"
  create-ants population[
    setxy nest-x nest-y
    set size 2
    set color black
    set has-food 0
    set direction random 360
  ]
end

to setup-food-sources
  create-food-sources Abundance-of-food [
    setxy random-xcor random-ycor
    set shape "grain"
    set size 4
    set nb-links 0
  ]
end

to setup-obstacles
  create-obstacles Number-of-obstacles [
    setxy random-xcor random-ycor
    set shape "stone"
    set color 33
    set size random 4 + 2
  ]
end

to setup-pheromones
  ask patches [ set ppheromones 0 ]
end

;======================;
;----Go procedures-----;
;======================;

to go
  move-ants
  touch-input
  tick
  wait 0.05
end

to move-ants
  ask ants [
    forward 1
    ; Add obstacle avoidance mechanism
    check-obstacles
    ifelse has-food = 1 [
      let max-patch max-one-of neighbors [nest-scent]
      face max-patch
      let target-patches patches in-radius 1 ; Define patches within a radius around the ant
      ask target-patches [
        set ppheromones ppheromones + 10  ; Increase pheromone levels on nearby patches
      ]
    ][
      if (ppheromones >= 0.05) [ uphill-pheromones ]
        check-food
      ]
    ]
   visualize-pheromones
end


to uphill-pheromones  ; turtle procedure. sniff left and right, and go where the strongest smell is
  let scent-ahead chemical-scent-at-angle   0
  let scent-right chemical-scent-at-angle  45
  let scent-left  chemical-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [
    ifelse scent-right > scent-left
      [ rt 45 ]
      [ lt 45 ]
  ]
end
to-report chemical-scent-at-angle [angle] ; reports the amount of pheromone in a certain direction
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [ppheromones] of p
end

to check-food
  ask ants [
    let target-food one-of food-sources in-radius 2
    if target-food != nobody[
      ifelse has-food = 0 [
        let food-source-links [nb-links] of target-food
        if food-source-links < 1[
        ; Pick up food
        set has-food 1
        create-link-with target-food [tie]
        ask target-food [set nb-links nb-links + 1]
        ]
      ] [
        ;stock food
        if distance patch nest-x nest-y < 3 [
          set food-stock food-stock + 1
          ask target-food [die]
          set has-food 0 ; Reset has-food flag
        ]
      ]
    ]
  ]
end

to visualize-pheromones
  ask patches [
    ifelse ppheromones > 0 [
      let lifespan 200 ; Set the lifespan of pheromones (adjust as needed)
      let age min (list ppheromones lifespan)
      let transparency 1 - (age / lifespan) ; Calculate transparency based on age

      ifelse age > 100 [
        set pcolor scale-color yellow (age - 100) 100 200 ; Transition to yellow after 50 ticks
      ] [
        set pcolor scale-color white age 0 100 ; Transition from white to yellow
      ]

      set pcolor (pcolor + (transparency * 50)) ; Apply transparency as an overlay

      set ppheromones (ppheromones - 1)
      if ppheromones < 0 [
        set ppheromones 0
      ]
      ; Decrease pheromone lifespan
    ]  [
      set pcolor 65  ; Reset patches without pheromones to default color
    ]
  ]
end






to check-obstacles
  ask ants [
    let target-obstacle one-of obstacles in-radius 3
    if target-obstacle != nobody[
       right random 180
    ]
  ]
end

; handles user touch input for chemicals, flowers, and vinegar
to touch-input
  if mouse-down?
  [
    ask patch mouse-xcor mouse-ycor
    [
    (ifelse
      add = "Pheromones"
      [
        ask neighbors [set ppheromones ppheromones + 60  ]
      ]
      add = "food"
      [
        if not any? food-sources in-radius 3  [sprout-food-sources 1
          [
            set shape "grain"
            set size 4
          ]
        ]
      ]
      add = "Vinegar"
      [
        set ppheromones 0 ask neighbors [set ppheromones 0  ]
      ]
    )
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
297
10
1098
552
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-30
30
-20
20
0
0
1
ticks
30.0

BUTTON
47
131
110
164
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
47
249
219
282
population
population
0
100
15.0
1
1
NIL
HORIZONTAL

TEXTBOX
34
23
267
73
Ants colony simulation
20
0.0
1

BUTTON
153
130
216
163
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
50
74
222
107
Abundance-of-food
Abundance-of-food
0
70
31.0
1
1
NIL
HORIZONTAL

SLIDER
47
190
219
223
Number-of-obstacles
Number-of-obstacles
0
50
9.0
1
1
NIL
HORIZONTAL

MONITOR
1120
23
1194
68
NIL
food-stock
17
1
11

CHOOSER
48
310
186
355
Add
Add
"food" "Pheromones" "Vinegar"
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

ant
true
0
Polygon -7500403 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7500403 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7500403 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -7500403 true true 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -7500403 true true 78 58 99 116 139 123 137 128 95 119
Polygon -7500403 true true 48 103 90 147 129 147 130 151 86 151
Polygon -7500403 true true 65 224 92 171 134 160 135 164 95 175
Polygon -7500403 true true 235 222 210 170 163 162 161 166 208 174
Polygon -7500403 true true 249 107 211 147 168 147 168 150 213 150

ant 2
true
0
Polygon -7500403 true true 150 19 120 30 120 45 130 66 144 81 127 96 129 113 144 134 136 185 121 195 114 217 120 255 135 270 165 270 180 255 188 218 181 195 165 184 157 134 170 115 173 95 156 81 171 66 181 42 180 30
Polygon -7500403 true true 150 167 159 185 190 182 225 212 255 257 240 212 200 170 154 172
Polygon -7500403 true true 161 167 201 150 237 149 281 182 245 140 202 137 158 154
Polygon -7500403 true true 155 135 185 120 230 105 275 75 233 115 201 124 155 150
Line -7500403 true 120 36 75 45
Line -7500403 true 75 45 90 15
Line -7500403 true 180 35 225 45
Line -7500403 true 225 45 210 15
Polygon -7500403 true true 145 135 115 120 70 105 25 75 67 115 99 124 145 150
Polygon -7500403 true true 139 167 99 150 63 149 19 182 55 140 98 137 142 154
Polygon -7500403 true true 150 167 141 185 110 182 75 212 45 257 60 212 100 170 146 172

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

grain
true
0
Polygon -1184463 true false 181 61 155 66 125 75 101 93 89 120 76 156 77 192 88 218 103 249 113 251 150 235 191 196 208 157 214 120 213 88 204 59 198 60
Polygon -955883 true false 201 59 190 97 170 141 137 198 110 240 139 213 167 173 194 118
Polygon -1 true false 83 177 97 127 130 80 104 102 90 131 82 177

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

stone
true
10
Polygon -6459832 true false 226 93 226 123 233 135 242 152 256 183 256 213 256 213 196 273 91 258 46 198 46 198 61 93 151 18 226 48 226 93
Polygon -16777216 true false 211 131 221 141 230 151 238 160 251 182 251 182 253 207 244 224 212 254 212 254 196 270 196 270 157 265 157 265 101 252 101 252 78 226 78 226 104 248 104 248 177 261 194 261 194 261 239 220 239 220 247 205 247 205 242 182 231 164
Polygon -1 true false 150 29 98 66 73 90 73 90 55 157 55 157 55 182 59 153 59 153 79 99
Line -16777216 false 232 178 245 205
Line -16777216 false 228 186 241 213
Line -16777216 false 225 195 238 222
Line -16777216 false 218 200 231 227
Line -16777216 false 211 207 224 234
Line -16777216 false 236 169 249 196
Line -16777216 false 205 213 218 240
Line -16777216 false 199 219 212 246
Line -16777216 false 193 225 206 252
Line -16777216 false 187 230 200 257
Line -16777216 false 182 237 193 259
Line -16777216 false 156 238 165 257
Line -16777216 false 149 241 157 258
Line -16777216 false 140 239 148 256
Line -16777216 false 131 239 138 253
Line -16777216 false 123 239 130 252
Line -16777216 false 114 236 121 249
Line -16777216 false 105 234 114 248
Line -16777216 false 97 232 104 245
Line -16777216 false 176 239 187 261
Line -16777216 false 170 239 181 261
Line -16777216 false 162 238 173 260

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tile stones
false
0
Polygon -7500403 true true 0 240 45 195 75 180 90 165 90 135 45 120 0 135
Polygon -7500403 true true 300 240 285 210 270 180 270 150 300 135 300 225
Polygon -7500403 true true 225 300 240 270 270 255 285 255 300 285 300 300
Polygon -7500403 true true 0 285 30 300 0 300
Polygon -7500403 true true 225 0 210 15 210 30 255 60 285 45 300 30 300 0
Polygon -7500403 true true 0 30 30 0 0 0
Polygon -7500403 true true 15 30 75 0 180 0 195 30 225 60 210 90 135 60 45 60
Polygon -7500403 true true 0 105 30 105 75 120 105 105 90 75 45 75 0 60
Polygon -7500403 true true 300 60 240 75 255 105 285 120 300 105
Polygon -7500403 true true 120 75 120 105 105 135 105 165 165 150 240 150 255 135 240 105 210 105 180 90 150 75
Polygon -7500403 true true 75 300 135 285 195 300
Polygon -7500403 true true 30 285 75 285 120 270 150 270 150 210 90 195 60 210 15 255
Polygon -7500403 true true 180 285 240 255 255 225 255 195 240 165 195 165 150 165 135 195 165 210 165 255

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
