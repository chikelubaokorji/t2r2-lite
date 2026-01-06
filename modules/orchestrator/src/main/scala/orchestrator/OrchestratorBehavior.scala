package orchestrator

import org.apache.pekko.actor.typed.{ActorRef, Behavior}
import org.apache.pekko.persistence.typed.PersistenceId
import org.apache.pekko.persistence.typed.scaladsl.{Effect, EventSourcedBehavior}
import contracts.RunSpec 

object OrchestratorBehavior {

  // --- Commands (Defines what the Actor can do) ---
  sealed trait Command
  case class StartRun(runId: String, spec: RunSpec, replyTo: ActorRef[Response]) extends Command
  case class UpdateTaskStatus(taskId: String, status: String) extends Command

  // --- Responses ---
  sealed trait Response
  case class RunAccepted(runId: String) extends Response

  // --- Events (Defines what is saved to the DB) ---
  sealed trait Event
  case class RunStarted(runId: String, spec: RunSpec) extends Event
  case class TaskStatusChanged(taskId: String, status: String) extends Event

  // --- State (The current memory of the run) ---
  case class State(runId: Option[String] = None, status: String = "IDLE")

  def apply(runId: String): Behavior[Command] = {
    EventSourcedBehavior[Command, Event, State](
      persistenceId = PersistenceId.ofUniqueId(s"run-$runId"),
      emptyState = State(),
      commandHandler = (state, command) => handleCommand(runId, state, command),
      eventHandler = (state, event) => handleEvent(state, event)
    )
  }

  private def handleCommand(id: String, state: State, command: Command): Effect[Event, State] = {
    command match {
      case StartRun(runId, spec, replyTo) =>
        Effect.persist(RunStarted(runId, spec))
          .thenRun { _ =>
            replyTo ! RunAccepted(runId)
          }

      case UpdateTaskStatus(taskId, status) =>
        Effect.persist(TaskStatusChanged(taskId, status))
    }
  }

  private def handleEvent(state: State, event: Event): State = {
    event match {
      case RunStarted(runId, _) =>
        state.copy(runId = Some(runId), status = "RUNNING")
      case TaskStatusChanged(_, status) =>
        state.copy(status = status)
    }
  }
}