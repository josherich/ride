module RouteRecordsHelper

	def seats_bar(seat_stat)
		if !seat_stat.to_s.include? '.'
			return 50
		end
		a = seat_stat.to_s.split('.')
		percentage = a[0].to_f / a[1].to_f * 100
		return percentage
	end

	def seats_text(seat_stat)
		if !seat_stat.to_s.include? '.'
			return '0/0'
		end
		a = seat_stat.to_s.split('.')
		return a[0] + '/' + a[1]
	end
end
