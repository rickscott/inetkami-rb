require 'uri'
require 'open-uri'

class InetkamiPlugin
class WeatherPlugin
    def initialize
        @metar_url = 'http://tgftp.nws.noaa.gov/data/observations/metar/stations/'
        @taf_url   = 'http://tgftp.nws.noaa.gov/data/forecasts/taf/stations/'

        return self
    end

    def commands
        return %w{wx metar taf}
    end

    def run(command, *args)
        station = args[0]

        unless station.match(/^[\w\d]{4}$/)
            return 'Invalid station id. Should be 4 letters/digits, eg "CYYZ", "K1J0"'
        end

        station.upcase!

        case command
            when /metar/i
                return metar(station)
            when /taf/i
                return taf(station)
            else
                return [metar(station), taf(station)]
        end
    end

    # the first line of a the METAR/TAF we retrieve is a datestamp
    # so we throw it away
    def metar(station)
        uri = URI("#{@metar_url}#{station}.TXT")

        begin
            return uri.open.readlines[1..-1].join
        rescue OpenURI::HTTPError
            return "No METAR available for #{station}. ☹"
        end
    end

    # TODO: collapse whitespace for TAFs; they oft format up p.badly
    def taf(station)
        uri = URI("#{@taf_url}#{station}.TXT")

        begin
            return uri.open.readlines[1..-1].join
        rescue OpenURI::HTTPError
            return "No TAF available for #{station}. ☹"
        end
    end

end
end
