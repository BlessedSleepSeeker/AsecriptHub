----------------------------------------------------------------------
-- Change the frames durations to match with easing functions
----------------------------------------------------------------------

-- Create three dialogs, one for each page
local dlg1 = Dialog("Frame Duration Easing - Variables")
local dlgs = { dlg1 }
local EASE_LINEAR = "Linear"
local EASE_IN_SINE = "Ease In Sine"
local EASE_OUT_SINE = "Ease Out Sine"
local EASE_IN_OUT_SINE = "Ease In Out Sine"
local EASE_IN_QUAD = "Ease In Quad"
local EASE_OUT_QUAD = "Ease Out Quad"
local EASE_IN_OUT_QUAD = "Ease In Out Quad"
local EASE_IN_CUBIC = "Ease In Cubic"
local EASE_OUT_CUBIC = "Ease Out Cubic"
local EASE_IN_OUT_CUBIC = "Ease In Out Cubic"
local EASE_IN_QUART = "Ease In Quart"
local EASE_OUT_QUART = "Ease Out Quart"
local EASE_IN_OUT_QUART = "Ease In Out Quart"
local EASE_IN_QUINT = "Ease In Quint"
local EASE_OUT_QUINT = "Ease Out Quint"
local EASE_IN_OUT_QUINT = "Ease In Out Quint"
local EASE_IN_EXPO = "Ease In Expo"
local EASE_OUT_EXPO = "Ease Out Expo"
local EASE_IN_OUT_EXPO = "Ease In Out Expo"
local EASE_IN_CIRC = "Ease In Circ"
local EASE_OUT_CIRC = "Ease Out Circ"
local EASE_IN_OUT_CIRC = "Ease In Out Circ"

local spr
local first_frame = 1
local last_frame = 0
local ms_budget = 1000
local ease_function = ""
local minimum_ms_duration = 2

local function normalizer(val, max, min)
  return (val - min) / (max - min);
end

local function denormalizer(val, max, min)
  return (val) * (max - min) + min;
end

local function easeInSine(x)
	return 1 - math.cos((x * math.pi) / 2)
end

local function easeOutSine(x)
	return math.sin((x * math.pi) / 2)
end

local function easeInOutSine(x)
	return -(math.cos(x * math.pi) - 1) / 2
end

local function easeInQuad(x)
	return x * x
end

local function easeOutQuad(x)
	return 1 - (1 - x) * (1 - x)
end

local function easeInOutQuad(x)
	local answer = 2 * x * x
	if x >= 0.5 then
		answer = 1 - ((-2 * x + 2)^2) / 2
	end
	return answer
end

local function easeInCubic(x)
	return x * x * x
end

local function easeOutCubic(x)
	return 1 - ((1 - x)^3);
end

local function easeInOutCubic(x)
	local answer = 4 * x * x * x
	if x >= 0.5 then
		answer = 1 - ((-2 * x + 2)^3) / 2
	end
	return answer
end

local function easeInQuart(x)
	return x * x * x * x
end

local function easeOutQuart(x)
	return 1 - ((1 - x)^4);
end

local function easeInOutQuart(x)
	local answer = 8 * x * x * x * x
	if x >= 0.5 then
		answer = 1 - ((-2 * x + 2)^4) / 2
	end
	return answer
end

local function easeInQuint(x)
	return x * x * x * x * x
end

local function easeOutQuint(x)
	return 1 - ((1 - x)^5);
end

local function easeInOutQuint(x)
	local answer = 16 * x * x * x * x * x
	if x >= 0.5 then
		answer = 1 - ((-2 * x + 2)^5) / 2
	end
	return answer
end

local function easeInExpo(x)
	local answer = 0
	if x > 0 then
		answer = 2^(10 * x - 10)
	end
	return answer
end

local function easeOutExpo(x)
	local answer = 1
	if x < 1 then
		answer = 1 - 2^(-10 * x)
	end
	return answer
end

local function easeInOutExpo(x)

	if x == 0 then
		return 0
	end
	if x == 1 then
		return 1
	end
	local answer =  (2 ^ (20 * x - 10)) / 2
	if x >= 0.5 then
		answer = (2 - (2 ^ (-20 * x + 10))) / 2
	end
	return answer
end

local function easeInCirc(x)
	return 1 - math.sqrt(1 - (x^2))
end

local function easeOutCirc(x)
	return math.sqrt(1 - ((x - 1)^ 2))
end

local function easeInOutCirc(x)
	local answer = (1 - math.sqrt(1 - ((2 * x)^ 2))) / 2
	if x >= 0.5 then
		answer = (math.sqrt(1 - ((-2 * x + 2)^2)) + 1) / 2
	end
	return answer
end


local function easeOutCirc(x)
  return math.sqrt(1 - ((x - 1)^2))
end

local function ease_dispatcher(x, linear_frame_time)
	local normalized = normalizer(x * linear_frame_time, ms_budget, 0)
	if ease_function == EASE_LINEAR then
			return linear_frame_time
	end
	if ease_function == EASE_IN_SINE then
		return easeInSine(normalized)
	end
	if ease_function == EASE_OUT_SINE then
		return easeOutSine(normalized)
	end
	if ease_function == EASE_IN_OUT_SINE then
		return easeInOutSine(normalized)
	end
	if ease_function == EASE_IN_QUAD then
		return easeInQuad(normalized)
	end
	if ease_function == EASE_OUT_QUAD then
		return easeOutQuad(normalized)
	end
	if ease_function == EASE_IN_OUT_QUAD then
		return easeInOutQuad(normalized)
	end
	if ease_function == EASE_IN_CUBIC then
		return easeInCubic(normalized)
	end
	if ease_function == EASE_OUT_CUBIC then
		return easeOutCubic(normalized)
	end
	if ease_function == EASE_IN_OUT_CUBIC then
		return easeInOutCubic(normalized)
	end
	if ease_function == EASE_IN_QUART then
		return easeInQuart(normalized)
	end
	if ease_function == EASE_OUT_QUART then
		return easeOutQuart(normalized)
	end
	if ease_function == EASE_IN_OUT_QUART then
		return easeInOutQuart(normalized)
	end
	if ease_function == EASE_IN_QUINT then
		return easeInQuint(normalized)
	end
	if ease_function == EASE_OUT_QUINT then
		return easeOutQuint(normalized)
	end
	if ease_function == EASE_IN_OUT_QUINT then
		return easeInOutQuint(normalized)
	end
	if ease_function == EASE_IN_EXPO then
		return easeInExpo(normalized)
	end
	if ease_function == EASE_OUT_EXPO then
		return easeOutExpo(normalized)
	end
	if ease_function == EASE_IN_OUT_EXPO then
		return easeInOutExpo(normalized)
	end
	if ease_function == EASE_IN_CIRC then
		return easeInCirc(normalized)
	end
	if ease_function == EASE_OUT_CIRC then
		return easeOutCirc(normalized)
	end
	if ease_function == EASE_IN_OUT_CIRC then
		return easeInOutCirc(normalized)
	end
end

local function reverse(tab)
    for i = 1, #tab//2, 1 do
        tab[i], tab[#tab-i+1] = tab[#tab-i+1], tab[i]
    end
    return tab
end

local function calculate_frames_duration()
	local frames_durations = {}
	local total_frames = tonumber(last_frame) - (tonumber(first_frame) - 1)
	if total_frames < 2 then
		error("Error : first frame : " .. first_frame)
		error("Error : last frame :" .. last_frame)
		return
	end

	local linear_frame_time = ms_budget / total_frames
	for var=1, total_frames do
		local result = ease_dispatcher(var, linear_frame_time)

		if ease_function == EASE_LINEAR then
			result = result / 1000
		else
			for _, frame_duration in ipairs(frames_durations) do
    			result = result - frame_duration
			end
		end
  		frames_durations[var] = result
	end

	local reversed_frames_durations = reverse(frames_durations)

	local sum = 0

	app.transaction("Frame Duration Easing",
		function ()
			for i, frame_duration in ipairs(reversed_frames_durations) do
				local ms_duration = frame_duration * ms_budget
				if ms_duration < tonumber(minimum_ms_duration) then
					ms_duration = tonumber(minimum_ms_duration)
				end
    			print(i, ":", math.ceil(ms_duration))
				local frame = spr.frames[i]
				-- duration is in seconds
				frame.duration = math.ceil(ms_duration) / 1000
				sum = sum + math.ceil(ms_duration)
			end
		end)
	print("sum of durations : ", sum)
end

local function cancelWizard(dlg)
  	dlg:close()
end

local function finalOK()
	first_frame = dlg1.data.first_frame
	last_frame = dlg1.data.last_frame
	ms_budget = dlg1.data.ms_budget
	ease_function = dlg1.data.ease_function
	minimum_ms_duration = dlg1.data.minimum_ms_duration

	calculate_frames_duration()
end

local function prevPage(dlg)
  dlg:close()
end

local function nextPage(dlg)
  dlg:close()
  finalOK()
end

local function addFooter(dlg, first, last)
  dlg:separator()
  if first then
    dlg:button{ text="&Cancel",onclick=function() cancelWizard(dlg) end }
  else
    dlg:button{ text="&Previous",onclick=function() prevPage(dlg) end }
  end

  local nextText
  if last then nextText = "&Finish" else nextText = "&Next" end
  dlg:button{ text=nextText, onclick=function() nextPage(dlg) end }
end

local function sum_of_durations(t)
    local sum = 0
    for _, v in ipairs(t) do
        sum = sum + v.duration * 1000
    end

    return sum
end

do
	spr = app.sprite
	if not spr then return app.alert "There is no active sprite" end

	local animation_duration = sum_of_durations(spr.frames)

	dlg1:separator{ text="Page 1" }
		:entry{ label="First Affected Frame", id="first_frame", text="1"}
		:entry{ label="Last Affected Frame", id="last_frame", text=tostring(#spr.frames)}
		:entry{ label="MilliSeconds Budget", id="ms_budget", text=tostring(animation_duration) }
		:combobox{  id="ease_function",
              label="Easing Function",
              option=EASE_IN_SINE,
              options={ EASE_IN_SINE, EASE_OUT_SINE, EASE_IN_OUT_SINE, EASE_IN_QUAD, EASE_OUT_QUAD, EASE_IN_OUT_QUAD, EASE_IN_CUBIC, EASE_OUT_CUBIC, EASE_IN_OUT_CUBIC, EASE_IN_QUART, EASE_OUT_QUART, EASE_IN_OUT_QUART, EASE_IN_QUINT, EASE_OUT_QUINT, EASE_IN_OUT_QUINT, EASE_IN_EXPO, EASE_OUT_EXPO, EASE_IN_OUT_EXPO, EASE_IN_CIRC, EASE_OUT_CIRC, EASE_IN_OUT_CIRC, EASE_LINEAR }}
		:entry{ label="Minimum MS Duration", id="minimum_ms_duration", text="20"}

	for i = 1,#dlgs do
  		addFooter(dlgs[i], (i == 1), (i == #dlgs))
	end

	dlg1:show{ wait=false }
end
