class HarmonyService
  def create_bookable(community_uuid, listing_uuid, author_uuid)
    res = HarmonyClient.post(
      :create_bookable,
      body: {
        marketplaceId: community_uuid,
        refId: listing_uuid,
        authorId: author_uuid
      },
      opts: {
        max_attempts: 3
      })

    if !res[:success] && res[:data][:status] == 409
      Result::Success.new("Bookable for listing with UUID #{listing_uuid} already created")
    else
      res
    end
  end
end