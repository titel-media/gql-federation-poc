defmodule ImageApi.Resolver do
  def execute(_), do: handle_value("ImageDelegated")

  def execute(_ctx, _obj, "_entities", %{"representations" => r}) do
    handle_value(r)
  end
  
  def execute(%{object_type: "ImageDelegated"}, %{"id" => id}, "id", _args), do: handle_value id

  def execute(%{object_type: "ImageDelegated"}, %{"id" => id}, "altText", _args) do
    seed(id)
    Faker.Lorem.paragraph(1)
    |> handle_value()
  end

  def execute(%{object_type: "ImageDelegated"}, %{"id" => id}, "url", _args) do
    seed(id)
    {width, height} = Faker.Util.pick([
      {768, 576},
      {640, 480},
      {480, 320},
      {352, 288},
      {nil, nil}
    ])
    %{
      "path" => random_image_path(),
      "width" => width,
      "height" => height,
    }
    |> thumbor_url() 
    |> handle_value()
  end

  def execute(_ctx, _obj, "_service", _args) do
    schema = File.open!("priv/schema.gql", [:read, :utf8], &IO.read(&1, :all))
             |> String.split("\n")
             |> Enum.reject(fn line -> String.match?(line, ~r/#federation/) end)
             |> Enum.join("\n")
    %{data: %{"sdl" => schema}}
    |> handle_value
  end

  def execute(_ctx, %{data: data}, field, _args) do
    Map.get(data, field, :null)
    |> handle_value
  end

  def execute(_ctx, _obj, _field, _args) do
    handle_value(:null)
  end

  def input(_, value), do: handle_value(value)
  def output(_, value), do: handle_value(value)

  defp handle_value(value) when is_list value do
    value = value
            |> Enum.map(fn v -> {:ok, v} end)
    {:ok, value}
  end

  defp handle_value(value), do: {:ok, value}

  defp thumbor_url(%{"path" => path} = data) do
    size =
      case data do
        %{"width" => w, "height" => h} ->
          "#{w || 0}x#{h || 0}"

        _ ->
          "0x0"
      end

    thumbor_path =
      case path do
        "http" <> _ -> "#{size}/#{path}"
        "/" <> _ -> "#{size}/#{static_host()}#{path}"
        path -> "#{size}/#{static_host()}/#{path}"
      end

    signature =
      :crypto.hmac(
        :sha,
        System.get_env("THUMBOR_KEY") || "DummyThumborKey",
        thumbor_path
      )
      |> Base.url_encode64()

    URI.parse("https://#{static_host()}")
    |> Map.put(:path, "/thumbor/#{signature}/#{thumbor_path}")
    |> URI.to_string()
  end

  defp seed(seed) when is_binary seed do
    String.to_integer(seed)
    |> seed
  end

  defp seed(seed) when is_integer seed do
    :random.seed(seed)
    :rand.seed(:exrop, {seed,1,1})
  end

  defp static_host, do: "static.highsnobiety.com"

  defp random_image_path do
    [
      "wp-content/uploads/selectism/2011/06/bonastre-fall2011-bags-mens-10.jpg",
      "wp-content/uploads/selectism/2011/06/viberg-scout-boot-tweed-1.jpg",
      "wp-content/uploads/2018/03/07201202/topo-designs-danner-spring-2018-capsule-000.jpg",
      "wp-content/uploads/selectism/2011/08/ce-10.jpg",
      "wp-content/uploads/selectism/2011/08/dries-van-noten-jacket-03.jpg",
      "wp-content/uploads/selectism/2011/08/ce-02.jpg",
      "wp-content/uploads/selectism/2011/07/apc-k-way-windbreaker-03.jpg",
      "wp-content/uploads/selectism/2011/08/instantology-spring-2012-jackets-07.jpg",
      "wp-content/uploads/2018/03/05230725/outlier-ultra-ultra-track-jacket-and-pants-09.jpg",
      "wp-content/uploads/2018/04/30143147/virgil-abloh-converse-all-star-release-date-price-2018-07.jpg",
      "wp-content/uploads/selectism/2011/09/beams-genteleman-wardrobe-3.jpg",
      "wp-content/uploads/selectism/2011/06/stanley-sons-denim-tote-bag-02.jpg",
      "wp-content/uploads/selectism/2011/11/Laszlo-skate-photos-03.jpg",
      "wp-content/uploads/2018/03/08135036/womens-sneakers-2.jpg",
      "wp-content/uploads/selectism/2010/11/mister-freedom-vest-02.jpg",
      "wp-content/uploads/2018/04/19153238/mago-dovneko-street-style-00.jpg",
      "wp-content/uploads/2018/04/19153420/mago-dovneko-street-style-04.jpg",
      "wp-content/uploads/2018/03/19165052/avengers-infinity-war-easter-eggs-in-post-05.jpg",
      "wp-content/uploads/2018/07/31113837/nike-acg-air-revaderchi-release-date-price-main-00.jpg",
      "wp-content/uploads/2018/07/16183253/mark-gonzales-adidas-skateboarding-20-year-anniversary-event-297.jpg",
      "wp-content/uploads/2018/07/14104648/some-ware-july-2018-2.jpg",
      "wp-content/uploads/2018/07/16203153/sheck-wes-helmut-lang-fall-2018-02.jpg",
      "wp-content/uploads/2018/07/16203206/sheck-wes-helmut-lang-fall-2018-04.jpg",
      "wp-content/uploads/2018/07/16220726/mtv-vma-2018-nominees-000.jpg",
      "wp-content/uploads/2018/07/16103019/band-of-outsiders-ss185.jpg",
      "wp-content/uploads/2018/07/31185127/elhaus-ss18-drop-2-25.jpg",
      "wp-content/uploads/2018/07/17094036/nike-react-fc-cr7-release-date-price-03.jpg",
      "wp-content/uploads/2018/07/01234202/Buddy-Highsnobiety-Thomas-Welch-05.jpg",
      "wp-content/uploads/2018/08/01122831/Untitled-312.jpg",
      "wp-content/uploads/2018/08/01151710/lester-jones-the-philippines-photography-feat2.jpg",
      "wp-content/uploads/2018/07/16164014/j-w-anderson-converse-chuck-70-toy-release-date-price-07.jpg",
      "wp-content/uploads/selectism/2010/05/blue-hour-store-tour-18.jpg",
      "wp-content/uploads/2018/07/16164113/j-w-anderson-converse-chuck-70-toy-release-date-price-16.jpg",
      "wp-content/uploads/2018/08/01190802/espn-the-ocho-comeback-feature.jpg",
      "wp-content/uploads/2018/07/17230649/engineered-garments-baracuta-fw18-capsule-01.jpg",
      "wp-content/uploads/2018/07/17132937/undefeated-hong-kong-nike-zoom-kobe-1-protro-release-date-price-04.jpg",
      "wp-content/uploads/2018/05/17145058/farfetch-sale-feature.jpg",
      "wp-content/uploads/selectism/2010/02/tag-book-1a.jpg",
      "wp-content/uploads/2018/07/17181448/mophie-apple-powerstations-07.jpg",
      "wp-content/uploads/2018/07/18162006/footpatrol-asics-gel-saga-anime-release-date-price-main-09.jpg",
      "wp-content/uploads/2018/07/18023652/d-face-clarks-collaboration-05.jpg",
      "wp-content/uploads/2018/07/18181634/yohji-yamamoto-dr-martens-1490-release-date-price-feature.jpg",
      "wp-content/uploads/selectism/2009/03/b-store-casio-collaboration-02.jpg",
      "wp-content/uploads/2018/07/18192918/air-jordan-1-low-flyknit-shattered-backboard-release-date-price-feature.jpg",
      "wp-content/uploads/2018/08/02180431/adidas-ultra-boost-dna-4.jpg",
      "wp-content/uploads/selectism/2009/02/neil-barrett-spring-2009-footwear-03.jpg",
      "wp-content/uploads/2018/07/18115121/nike-air-skylon-2-release-date-price-10.jpg",
      "wp-content/uploads/2018/07/18115107/nike-air-skylon-2-release-date-price-11.jpg",
      "wp-content/uploads/2018/07/18115204/nike-air-skylon-2-release-date-price-02.jpg",
      "wp-content/uploads/2018/07/18151223/brockhampton-the-best-years-of-our-lives-album-details-feat.jpg",
      "wp-content/uploads/2018/08/03183823/maharishi-suka-tracksuit-000.jpg",
      "wp-content/uploads/selectism/2009/02/resterods-autumn-winter-2009-collection-02.jpg",
      "wp-content/uploads/2018/08/02183207/hublot-classic-fusion-aerofusion-chronograph-capri-02.jpg",
      "wp-content/uploads/2018/08/02191257/apple-one-trillion-dollar-company-000.jpg",
      "wp-content/uploads/2018/07/18172703/bape-adidas-originals-adicolor-fw18-22.jpg",
      "wp-content/uploads/2018/08/02214655/nike-best-running-shoe-chart-001.jpg",
      "wp-content/uploads/2018/08/03210638/coco-capitan-is-it-tomorrow-yet-daelim-museum-14.jpg",
      "wp-content/uploads/2018/07/18234815/pam-fw18-23.jpg",
      "wp-content/uploads/2018/08/03214109/travis-scott-wav-radio-astroworld-episode-feature.jpg",
      "wp-content/uploads/2018/07/18222125/robert-geller-ss19-09.jpg",
      "wp-content/uploads/2018/08/02235003/hajime-sorayama-huf-capsule-01.jpg",
      "wp-content/uploads/2018/07/05103018/travis-scott-astroworld-merch-collection-28.jpg",
      "wp-content/uploads/2018/08/03113359/37777133_649290475455138_8249980616192294912_n.jpg",
      "wp-content/uploads/2018/07/19101846/nike-air-max-97-just-do-it-release-date-price-04.jpg",
      "wp-content/uploads/2018/07/19144825/tyler-the-creator-flower-boy-anniversary-01.jpg",
      "wp-content/uploads/2018/08/03103659/breaking-bad-Ozymandias-unscripted-01.jpg",
      "wp-content/uploads/2018/07/19151801/college-aries-antick-loafer-release-date-price-04.jpg"
    ]
    |> Faker.Util.pick()
  end
end
