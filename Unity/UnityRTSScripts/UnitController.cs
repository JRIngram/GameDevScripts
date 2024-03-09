using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class UnitController : MonoBehaviour
{

    /// The type of unit the UnitController controllers
    public GameObject unitType;

    /// The number of agents within the unit
    public int agentCount;

    /// The agents the UnitController controls
    private GameObject[] agents;

    /// The radius from the UnitController where units can spawn
    public float spawnRadius;

    /// The distance an agent should spawn from an already occupied spawn point
    public float distanceFromOccupiedSpawnPosition;
    
    /// The valid states of the UnitController
    public enum States{ 
        SELECTED,
        DESELECTED,
    }

    public States state;

    // Start is called before the first frame update
    void Start()
    {
        state = States.DESELECTED;
        agents = new GameObject[agentCount];
        Vector3 currentPosition = this.transform.position;

        // Spawns UnitAgents in a random position within a radius of the UnitController
        for(int i = 0; i < agentCount; i++){
            float randomX = Random.Range(-spawnRadius + currentPosition.x, spawnRadius + currentPosition.x);
            float randomZ = Random.Range(-spawnRadius + currentPosition.z, spawnRadius + currentPosition.z);
            Vector3 randomSpawnPosition = new Vector3(randomX, currentPosition.y, randomZ);
            
            while(isSpawnSpaceOccupiedByAgent(randomSpawnPosition)){
                randomX = Random.Range(-spawnRadius + currentPosition.x, spawnRadius + currentPosition.x);
                randomZ = Random.Range(-spawnRadius + currentPosition.z, spawnRadius + currentPosition.z);
                randomSpawnPosition = new Vector3(randomX, currentPosition.y, randomZ);
            }

            NavMeshHit hit;
            NavMesh.SamplePosition(randomSpawnPosition, out hit, 1.0f, NavMesh.AllAreas);
            GameObject unit = Instantiate(unitType);
            unit.transform.SetParent(transform);
            unit.GetComponent<NavMeshAgent>().Warp(hit.position);
            agents[i] = unit;

        }
    }

    // Update is called once per frame
    void Update()
    {

    }

    
    /// Checks if the spawnPosition is occupied by another agents position that is controlled by this UnitController.
    /// Returns true if occupied by another agent, false if not occupied.
    /// <param name="spawnPosition"> The position to check if it is occupied by another agent</param>
    /// <returns> bool if the spawnPosition is occupied by another agent </returns>
    bool isSpawnSpaceOccupiedByAgent(Vector3 spawnPosition){
        for(int i = 0; i < agents.Length; i++){
            GameObject agent = agents[i];
            if(agent != null){
                float agentXUpperBound = agent.transform.position.x + distanceFromOccupiedSpawnPosition;
                float agentXLowerBound = agent.transform.position.x - distanceFromOccupiedSpawnPosition;
                float agentZUpperBound = agent.transform.position.z + distanceFromOccupiedSpawnPosition;
                float agentZLowerBound = agent.transform.position.z - distanceFromOccupiedSpawnPosition;
                if(spawnPosition.x < agentXUpperBound && spawnPosition.x > agentXLowerBound){
                    return true;
                }
                if(spawnPosition.z < agentZUpperBound && spawnPosition.z > agentZLowerBound){
                    return true;
                }
            }
        }
        return false;
    }

    /// Returns the UnitAgents within the UnitController
    public GameObject[] getAgents(){
        return agents;
    }


    /// Returns if the UnitController is selected or not
    public bool isUnitSelected(){
        bool isSelected = this.state == States.SELECTED ? true : false;
        return isSelected;
    }


    /// Sets the state of the UnitController and then the state of all UnitAgents in the UnitController
    public void setUnitState(string state){
        if(state == "selected"){
            this.state = States.SELECTED;
        }
        else if(state == "deselected"){
            this.state = States.DESELECTED;
        }
        setAgentsSelectedStates();
    }

    /// Sets the state of all UnitAgents within the UnitController
    void setAgentsSelectedStates(){
        for(int i = 0; i < agents.Length; i++){
            GameObject agent = agents[i];
            if(state == States.SELECTED){
                agent.GetComponent<UnitAgent>().setState("selected");
            }
            else if(state == States.DESELECTED){
                agent.GetComponent<UnitAgent>().setState("deselected");
            }
        }
    }
}