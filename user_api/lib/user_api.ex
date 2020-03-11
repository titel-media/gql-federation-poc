defmodule UserApi do
  use Application
  require Logger

  def start_phase(:load_graphql_schema, _, []) do
  
    IO.puts """

#     #                         #    ######  ### 
#     #  ####  ###### #####    # #   #     #  #  
#     # #      #      #    #  #   #  #     #  #  
#     #  ####  #####  #    # #     # ######   #  
#     #      # #      #####  ####### #        #  
#     # #    # #      #   #  #     # #        #  
 #####   ####  ###### #    # #     # #       ### 
                                                 
"""

    :ok = UserApi.Schema.load()
  end

  def start(_type, args) do
    import Supervisor.Spec

    children = [
      {HTTP, []}
    ]
    opts = [strategy: :one_for_one, name: UserApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
