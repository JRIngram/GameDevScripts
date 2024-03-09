using UnityEngine;
using UnityEngine.AI;

public class UnitAgent : MonoBehaviour
{
    /// The navmesh agent for the agent
    private NavMeshAgent agent;


    /// The valid states of a UnitAgent
    public enum States{ 
        SELECTED,
        DESELECTED,
    }

    /// The current state of the agent
    public States state;

    /// The renderer for the agent
    private Renderer agentRenderer;

    void Awake(){
        state = States.DESELECTED;
        agent = GetComponent<NavMeshAgent>();
        agentRenderer = transform.gameObject.GetComponent<Renderer>();
        setColourToMatchState();
    }

    void Start()
    {

    }

    void Update() {
        if (Input.GetMouseButtonDown(1)) {
            setMoveToLocation();
        }
    }

    /// Sets the NavMeshAgents destination to where the mouse is
    void setMoveToLocation(){
        if(state == States.SELECTED){
            RaycastHit hit;
            Vector3 mousePosition = Input.mousePosition;
            if (Physics.Raycast(Camera.main.ScreenPointToRay(mousePosition), out hit, 100)) {
                Vector3 goalLocation = hit.point;
                Vector3 agentPosition = agent.transform.position;
                agent.destination = goalLocation;
            }
        }

    }

    /// Sets the state of the UnitAgent
    /// <param name="state">A string, should be either "selected" or "deselected"</param>
    public void setState(string state){
        switch (state)
        {
            case "selected":
                this.state = States.SELECTED;
                break;
            case "deselected":
                this.state = States.DESELECTED;
                break;
            default:
                throw new System.ArgumentException("Parameter must be either \"selected\" or \"deselected\"");
        }
        setColourToMatchState();
    }

    
    /// Sets the colour of the agent game objects based on the state of the agent
    /// <see> UnitAgent.States </see>
    void setColourToMatchState(){
        if(state == States.SELECTED){
            agentRenderer.material.SetColor("_Color", Color.green);
        }
        else if(state == States.DESELECTED){
            agentRenderer.material.SetColor("_Color", Color.blue);
        }
    }
}