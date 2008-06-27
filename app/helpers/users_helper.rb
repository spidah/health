module UsersHelper
  def time_zone_options(selected = nil)
    zone_options = ""

    zones = TZInfo::Timezone.all
    convert_zones = lambda { |list| list.map { |z| [ z.identifier, z.to_s ] } }

    zone_options += options_for_select(convert_zones[zones], selected)
    zone_options
  end
end
