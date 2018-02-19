package org.itemis.main.rest

import javax.ws.rs.Path
import javax.ws.rs.POST
import javax.ws.rs.Produces
import javax.ws.rs.core.MediaType
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import javax.ws.rs.core.Response
import org.itemis.main.SessionController

@Path("/")
final class SessionControllerREST {
  private static final Logger LOGGER = LoggerFactory.getLogger("SessionController")
  
  @POST
  @Path("/shutdown")
  @Produces(MediaType.APPLICATION_JSON)
  def Response shutdownServer() {
    LOGGER.warn("received shutdown signal - shutting down")
    SessionController.shutdown
    Response.status(Response.Status.OK).build
  }
  
  @POST
  @Path("/startNode")
  @Produces(MediaType.APPLICATION_JSON)
  def Response startNode() {
    LOGGER.warn("starting Node")
    SessionController.startNode
    Response.status(Response.Status.OK).build
  }
  
  @POST
  @Path("/shutdownNode")
  @Produces(MediaType.APPLICATION_JSON)
  def Response shutdownNode() {
    LOGGER.warn("shutting down Node")
    SessionController.shutdownNode
    Response.status(Response.Status.OK).build
  }
}