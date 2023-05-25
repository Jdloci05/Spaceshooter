using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PlayerControl : MonoBehaviour
{
    public GameObject GameManagerGO;

    public GameObject PlayerBulletGO;
    public GameObject BulletPosition01;
    public GameObject BulletPosition02;
    public GameObject ExplosionGO;

    public AudioSource audioSource;

    public TCPClient ControllerTCP;

    public Text LivesUIText;

    const int MaxLives = 3;
    int Lives;

    public float speed;

    float x;
    float y;

    public void Init()
    {
        Lives = MaxLives;

        LivesUIText.text = Lives.ToString();

        transform.position = new Vector2(107, 52);

        gameObject.SetActive(true);
    }

    // Start is called before the first frame update
    void Start()
    {
        ControllerTCP = GetComponent<TCPClient>();
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKeyDown("space"))
        {
            audioSource.Play();

            GameObject bullet01 = (GameObject)Instantiate(PlayerBulletGO);
            bullet01.transform.position = BulletPosition01.transform.position;

            GameObject bullet02 = (GameObject)Instantiate(PlayerBulletGO);
            bullet02.transform.position = BulletPosition02.transform.position;
        }

          if(ControllerTCP.socketReady == true)
          {
              x = ControllerTCP.getTcpX()  ;
              y = ControllerTCP.getTcpY() ;
          }
          else
          {
           x = Input.GetAxisRaw("Horizontal");
           y = Input.GetAxisRaw("Vertical");
          }


        Vector2 direction = new Vector2(x, y).normalized;

        Move(direction);
    }

    void Move(Vector2 direction)
    {
        Vector2 min = Camera.main.ViewportToWorldPoint(new Vector2(0, 0));
        Vector2 max = Camera.main.ViewportToWorldPoint(new Vector2(1, 1));

        max.x = max.x - 0.225f;
        min.x = min.x - 0.225f;

        max.y = max.y - 0.285f;
        min.y = min.y - 0.285f;

        Vector2 pos = transform.position;

        pos += direction * speed * Time.deltaTime;

        pos.x = Mathf.Clamp(pos.x, min.x, max.x);
        pos.y = Mathf.Clamp(pos.y, min.y, max.y);

        transform.position = pos;
    }

     void OnTriggerEnter2D(Collider2D col)
    {
        if((col.tag == "EnemyShipTag") || (col.tag == "EnemyBulletTag"))
        {
            PlayExplosion();

            Lives--;
            LivesUIText.text = Lives.ToString();

              if(Lives ==0)
              {
                  GameManagerGO.GetComponent<GameManager>().SetGameManagerState(GameManager.GameManagerState.GameOver);

                  gameObject.SetActive(false);
              }
        }
    }

    void PlayExplosion()
    {
        GameObject explosion = (GameObject)Instantiate(ExplosionGO);

        explosion.transform.position = transform.position;
    }
}
